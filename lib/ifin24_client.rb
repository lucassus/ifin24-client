class Ifin24Client
  def initialize(login, password)
    @login = login
    @password = password
    
    @agent = Mechanize.new

    login()
  end

  def fetch_categories
    @agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
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
        id = sub_category_elem.attributes['rel'].value

        sub_categories[sub_name] = id
      end

      categories[category_name] = sub_categories
    end

    return categories
  end

  def fetch_accounts
    @agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
    accounts_element = @agent.page.search('ul#bankAccountCombo>li')

    accounts = {}
    accounts_element.each do |account_elem|
      id = account_elem.attributes['rel'].value
      next if id == '0' # skip the prompt
      name = account_elem.text.strip

      accounts[name] = id
    end

    return accounts
  end

  def send_entry(entry)
    @agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
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

  private

  def login
    @agent.get('https://www.ifin24.pl/logowanie')
    login_form = @agent.page.forms.first

    login_form['login'] = @login
    login_form['password'] = @password

    login_form.submit
  end
end
