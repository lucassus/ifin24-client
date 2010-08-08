require 'rubygems'
require 'bundler'
Bundler.setup

require 'mechanize'

agent = Mechanize.new

# Login
agent.get('https://www.ifin24.pl/logowanie')
login_form = agent.page.forms.first
login_form['login'] = 'ifin24_console'
login_form['password'] = 'ifin24_console'
login_form.submit

def fetch_categories(categories_element)
  categories = {}

  categories_element[1..-1].each do |cat|
    next if cat.children[1].nil?
    
    category_name = cat.children[0].text.strip
    sub_categories_element = cat.children[1].children.search('li')

    sub_categories = {}
    sub_categories_element.each do |sub_cat|
      sub_name = sub_cat.text.strip
      id = sub_cat.attributes['rel'].value

      sub_categories[id] = sub_name
    end

    categories[category_name] = sub_categories
  end

  return categories
end

# Fetch categories
agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
element = agent.page.search('ul.expenseCombo>li')
categories = fetch_categories(element)
pp categories

# Add entry
agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
form = agent.page.forms.first
form['entry.title'] = 'Foo'
form['entry.date'] = Date.today.to_s
form['selectedBankAccount'] = '3968'
form['entry.entryCategory.id'] = '113'
form['entry.amount'] = '99.99'
form['entry.note'] = 'Lorem ipsum'
form.submit

