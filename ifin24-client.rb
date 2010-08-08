#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup

require 'yaml'
require 'mechanize'
require 'highline/import'

def login(agent, login, password)
  agent.get('https://www.ifin24.pl/logowanie')
  login_form = agent.page.forms.first

  login_form['login'] = login
  login_form['password'] = password
  
  login_form.submit
end

def fetch_categories(agent)
  categories_element = agent.page.search('ul.expenseCombo>li')

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

def fetch_accounts(agent)
  accounts_element = agent.page.search('ul#bankAccountCombo>li')

  accounts = {}
  accounts_element.each do |account_elem|
    id = account_elem.attributes['rel'].value
    next if id == '0' # skip the prompt
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
  form['entry.entryCategory.id'] = data[:subcategory_id].to_s
  form['entry.amount'] = data[:amount].to_s
  form['value'] = data[:tags].to_s
  form['entry.note'] = data[:note].to_s

  form.submit
end

def get_data(agent)
  # Fetch categories and accounts
  agent.get('https://www.ifin24.pl/zarzadzanie-finansami/transakcje/dodaj-wydatek')
  categories = fetch_categories(agent)
  accounts = fetch_accounts(agent)

  data = {}
  data[:title] = ask('Nazwa')

  curr_date = Date.today
  data[:date] = ask("Data (#{curr_date})")
  data[:date] = curr_date.to_s if data[:date].empty?

  data[:account_id] = nil
  choose do |menu|
    menu.prompt = 'Wybierz rachunek'

    accounts.each do |name, id|
      menu.choice(name) do
        data[:account_name] = name
        data[:account_id] = id
      end
    end
  end

  sub_categories = {}
  choose do |menu|
    menu.prompt = 'Wybierz kategorię'

    categories.each do |name, sub|
      menu.choice(name) do
        data[:category_name] = name
        sub_categories = sub
      end
    end
  end


  data[:subcategory_id] = nil
  choose do |menu|
    menu.prompt = 'Wybierz podkategorię'

    sub_categories.each do |name, id|
      menu.choice(name) do
        data[:subcategory_name] = name
        data[:subcategory_id] = id
      end
    end
  end

  data[:amount] = ask('Kwota')
  data[:tags] = ask('Tagi')
  data[:note] = ask('Opis')

  return data
end

def print_data(data)
  puts "=" * 16
  puts "Nazwa: #{data[:title]}"
  puts "Data: #{data[:date]}"
  puts "Rachunek: #{data[:account_name]}"
  puts "Kwota: #{data[:amount]}"
  puts "Kategoria: #{data[:category_name]} / #{data[:subcategory_name]}"
  puts "Tagi: #{data[:tags]}"
  puts "Opis: #{data[:note]}"
  puts "=" * 16
end

def load_config
  file_name = File.join(ENV['HOME'], '.ifin24-client', 'config.yml')
  if File.exist?(file_name)
    YAML.load_file(file_name) rescue {}
  else
    puts "Nie odnaleziono pliku konfiguracyjnego #{file_name}"
    exit
  end
end

def main
  agent = Mechanize.new

  # login
  config = load_config
  login(agent, config[:login], config[:password])

  # add entry
  loop do
    choose do |menu|
      menu.layout = :menu_only
      menu.shell  = true

      menu.choices(:dodaj, :add, :a) do
        data = get_data(agent)
        print_data(data)
        if agree("Dane poprawne?")
          puts "Wysyłanie danych.."
          add_entry(agent, data)
        end
      end

      menu.choices(:koniec, :exit, :q) do
        exit
      end
    end
  end
end

main
