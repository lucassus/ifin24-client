require 'rubygems'
require 'bundler'
Bundler.setup

require 'mechanize'
require 'highline/import'

# Login
def login(agent, login, password)
  agent.get('https://www.ifin24.pl/logowanie')
  login_form = agent.page.forms.first

  login_form['login'] = login
  login_form['password'] = password
  
  login_form.submit
end

def fetch_categories(categories_element)
  categories = {}

  categories_element[1..-1].each do |category_elem|
    next if category_elem.children[1].nil?
    
    category_name = category_elem.children[0].text.strip
    sub_categories_element = category_elem.children[1].children.search('li')

    sub_categories = {}
    sub_categories_element.each do |sub_cat|
      sub_name = sub_cat.text.strip
      id = sub_cat.attributes['rel'].value

      sub_categories[sub_name] = id
    end

    categories[category_name] = sub_categories
  end

  return categories
end

def fetch_accounts(accounts_element)
  accounts = {}

  accounts_element.each do |account_elem|
    id = account_elem.attributes['rel'].value
    next if id == '0'
    name = account_elem.text.strip

    accounts[name] = id
  end

  return accounts
end

def add_entry(agent, data)
  agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
  form = agent.page.forms.first

  form['entry.title'] = data[:title].to_s
  form['entry.date'] = data[:date].to_s
  form['selectedBankAccount'] = data[:account_id].to_s
  form['entry.entryCategory.id'] = data[:category_id].to_s
  form['entry.amount'] = data[:amount].to_s
  form['entry.note'] = data[:note].to_s

  form.submit
end

def get_data(agent)
  # Fetch categories and accounts
  agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
  element = agent.page.search('ul.expenseCombo>li')
  categories = fetch_categories(element)

  element = agent.page.search('ul#bankAccountCombo>li')
  accounts = fetch_accounts(element)

  data = {}
  data[:title] = ask('Nazwa')

  curr_date = Date.today
  data[:date] = ask("Data (#{curr_date})")
  data[:date] = curr_date.to_s if data[:date].empty?

  data[:account_id] = nil
  choose do |menu|
    menu.prompt = 'Wybierz rachunek'

    accounts.each do |name, id|
      menu.choice(name) { data[:account_id] = id }
    end

  end

  sub_categories = {}
  choose do |menu|
    menu.prompt = 'Wybierz kategorie'

    categories.each do |name, sub|
      menu.choice(name) { sub_categories = sub }
    end
  end


  data[:category_id] = nil
  choose do |menu|
    menu.prompt = 'Wybierz podkategorie'

    sub_categories.each do |name, id|
      menu.choice(name) { data[:category_id] = id }
    end
  end

  data[:amount] = ask('Kwota')
  data[:note] = ask('Opis')

  return data
end

def main
  agent = Mechanize.new
  login(agent, 'ifin24_console', 'ifin24_console')
  data = get_data(agent)
  add_entry(agent, data)
end

main()
