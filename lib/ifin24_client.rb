class Ifin24Client

  LOGIN_FORM_URL = 'https://www.ifin24.pl/logowanie'
  ENTRY_FORM_URL = 'https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek'
  LIST_URL = 'https://www.ifin24.pl/zarzadzanie-finansami/transakcje/lista'

  def initialize(login, password)
    @login, @password = login, password
    @agent = Mechanize.new

    login()
  end

  def fetch_categories
    @agent.get(ENTRY_FORM_URL)
    categories_element = @agent.page.search('ul.expenseCombo>li')

    categories = {}
    categories_element[1..-1].each do |category_elem|
      category_without_children = category_elem.children[1].nil?
      next if category_without_children

      category_name = category_elem.children[0].text.strip
      sub_categories_element = category_elem.children[1].children.search('li')

      sub_categories = {}
      sub_categories_element.each do |sub_category_elem|
        sub_name = sub_category_elem.text.strip
        sub_id = sub_category_elem.attributes['rel'].value

        sub_categories[sub_name] = sub_id
      end

      categories[category_name] = sub_categories
    end

    return categories
  end

  def fetch_accounts
    @agent.get(ENTRY_FORM_URL)
    accounts_element = @agent.page.search('ul#bankAccountCombo>li')

    accounts = []
    accounts_element.each do |account_elem|
      id = account_elem.attributes['rel'].value
      next if id == '0' # skip the prompt
      name = account_elem.text.strip

      accounts << Account.new(id, name)
    end

    return accounts
  end

  def send_entry(entry)
    @agent.get(ENTRY_FORM_URL)
    form = @agent.page.forms.first

    form['entry.title'] = entry.title.to_s
    form['entry.date'] = entry.date.to_s
    form['selectedBankAccount'] = entry.account_id.to_s
    form['entry.entryCategory.id'] = entry.subcategory_id.to_s
    form['entry.amount'] = entry.amount.to_s
    form['value'] = entry.tags.to_s
    form['entry.note'] = entry.note.to_s

    form.submit
  end

  def fetch_list
    @agent.get(LIST_URL)
    entry_row_elements = @agent.page.search('table tbody tr')

    entries = []

    entry_row_elements.each do |entry_row_element|
      entry_elements = entry_row_element.search('td')
      next if entry_elements.size != 5

      entry = Entry.new

      title_column = entry_elements[2]
      entry.title = title_column.children[0].text.strip
      entry.note = title_column.search('span').text.strip

      date_column = entry_elements[1]
      entry.date = date_column.text.strip

      category_column = entry_elements[3]
      entry.subcategory_name = category_column.children[0].text.strip
      entry.tags = category_column.search('span').text.strip

      amount_column = entry_elements[4]
      entry.amount = amount_column.text.strip

      entries << entry
    end

    return entries
  end

  private

  def login
    @agent.get(LOGIN_FORM_URL)
    form = @agent.page.forms.first

    form['login'] = @login
    form['password'] = @password

    form.submit
  end

end
