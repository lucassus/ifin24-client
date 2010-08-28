require 'mechanize'

class Ifin24::Client

  LOGIN_FORM_URL = 'https://www.ifin24.pl/logowanie'
  ENTRY_FORM_URL = 'https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek'
  
  LIST_URL = 'https://www.ifin24.pl/zarzadzanie-finansami/transakcje/lista'
  LIMITS_URL = 'https://www.ifin24.pl/zarzadzanie-finansami/kontrola-wydatkow'

  def initialize(login, password)
    @login, @password = login, password
  end

  def agent
    @agent ||= Mechanize.new
  end

  def agent=(agent)
    @agent = agent
  end

  def categories
    @categories ||= fetch_categories
  end

  def accounts
    fetch_accounts
  end

  def send_entry(entry)
    page = agent.get(ENTRY_FORM_URL)
    form = page.forms.first

    form['entry.title'] = entry.title.to_s
    form['entry.date'] = entry.date.to_s
    form['selectedBankAccount'] = entry.account.id.to_s
    form['entry.entryCategory.id'] = entry.sub_category.id.to_s
    form['entry.amount'] = entry.amount.to_s
    form['value'] = entry.tags.to_s
    form['entry.note'] = entry.note.to_s

    form.submit
  end

  def fetch_entries(curr_page = 1)
    page = agent.get("#{LIST_URL}?pageNumber=#{curr_page}")
    total_pages = extract_entries_total_pages(page)
    entry_row_elements = page.search('table tbody tr')

    entries = []

    entry_row_elements.each do |entry_row_element|
      entry_elements = entry_row_element.search('td')
      next if entry_elements.size != 5

      entry = Ifin24::Models::Entry.new

      title_column = entry_elements[2]
      entry.title = title_column.children[0].text.strip
      entry.note = title_column.search('span').text.strip

      date_column = entry_elements[1]
      entry.date = date_column.text.strip

      category_column = entry_elements[3]
      sub_category = Ifin24::Models::Category.new(:name => category_column.children[0].text.strip)
      entry.sub_category = sub_category
        
      entry.tags = category_column.search('span').text.strip
      amount_column = entry_elements[4]
      entry.amount = amount_column.text.strip

      entries << entry
    end

    return entries, total_pages
  end

  def fetch_limits
    page = agent.get(LIMITS_URL)

    limits = []

    table = page.search('table#expenses-tracking-limits tbody')
    table.search('tr').each do |tr|
      limit = Ifin24::Models::Limit.new
      columns = tr.search('td')

      name_column = columns[0]
      limit.name = name_column.text.strip

      amounts_column = columns[2]
      match = amounts_column.text.strip.match(/^(?<amount>\d+,\d+) PLN z (?<max>\d+,\d+) PLN$/)
      if match
        limit.amount = sanitize_price(match['amount'])
        limit.max = sanitize_price(match['max'])
      end

      limits << limit
    end

    return limits
  end

  def login
    page = agent.get(LOGIN_FORM_URL)
    form = page.forms.first

    form['login'] = @login
    form['password'] = @password

    page = form.submit
    @logged = page.forms.first.nil?

    return logged?
  end

  def logged?
    @logged
  end

  private

  def fetch_categories
    page = agent.get(ENTRY_FORM_URL)
    categories_element = page.search('ul.expenseCombo>li')

    categories = []
    categories_element[1..-1].each do |category_elem|
      category_without_children = category_elem.children[1].nil?
      next if category_without_children

      category_name = category_elem.children[0].text.strip
      category = Ifin24::Models::Category.new(:name => category_name)
      children_element = category_elem.children[1].children.search('li')

      children_element.each do |child_elem|
        child_id = child_elem.attributes['rel'].value
        child_name = child_elem.text.strip

        child = Ifin24::Models::Category.new(:id => child_id, :name => child_name)
        category.children << child
      end

      categories << category
    end

    return categories
  end

  def fetch_accounts
    page = agent.get(ENTRY_FORM_URL)
    accounts_element = page.search('ul#bankAccountCombo>li')

    accounts = []
    accounts_element.each do |account_elem|
      id = account_elem.attributes['rel'].value
      next if id == '0' # skip the prompt
      name = account_elem.text.strip

      accounts << Ifin24::Models::Account.new(:id => id, :name => name)
    end

    return accounts
  end

  def extract_entries_total_pages(page)
    links = page.search('div.pager a')
    return links[-2].text.to_i
  end

  def sanitize_price(price)
    return 0.0 if price.nil?
    return price.strip.gsub(',', '.').to_f
  end

end
