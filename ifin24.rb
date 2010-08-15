#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup

require 'yaml'
require 'mechanize'
require 'highline/import'

require 'lib/ifin24/client'
require 'lib/models/account'
require 'lib/models/category'
require 'lib/models/entry'

def get_entry(client)
  entry = Entry.new
  entry.title = ask('Nazwa: ')

  curr_date = Date.today
  entry.date = ask('Data: ') do |q|
    q.default = curr_date
  end

  choose do |menu|
    menu.prompt = 'Wybierz rachunek: '

    client.accounts.each do |account|
      menu.choice(account.name) do
        entry.account_name = account.name
        entry.account_id = account.id
      end
    end
  end

  sub_categories = {}
  choose do |menu|
    menu.prompt = 'Wybierz kategorię: '

    client.categories.each do |category|
      menu.choice(category.name) do
        entry.category_name = category.name
        sub_categories = category.sub_categories
      end
    end
  end

  choose do |menu|
    menu.prompt = 'Wybierz podkategorię: '

    sub_categories.each do |category|
      menu.choice(category.name) do
        entry.subcategory_name = category.name
        entry.subcategory_id = category.id
      end
    end
  end

  entry.amount = eval ask('Kwota: ')
  entry.tags = ask('Tagi: ')
  entry.note = ask('Opis: ')

  return entry
end

def load_config
  file_name = File.join(ENV['HOME'], '.ifin24-client', 'config.yml')
  if File.exist?(file_name)
    YAML.load_file(file_name) rescue {}
  else
    puts "Nie odnaleziono pliku konfiguracyjnego: #{file_name}"
    exit
  end
end

def add_entry(client)
  entry = get_entry(client)

  puts entry.to_s
  if agree("Dane poprawne? ")
    puts "Wysyłanie danych..."
    client.send_entry(entry)
  end
end

def list_accounts(client)
  print_list(client.accounts, :name)
end

def print_entries(list)
  print_list(list, :date, :title, :subcategory_name, :tags, :amount)
end

def list_entries(client)
  current_page = 1
  list, pages = client.fetch_entries(current_page)
  print_entries(list)

  catch :exit do
    loop do
      choose do |menu|
        menu.index = :letter
        menu.index_suffix = ") "
        menu.shell = true

        menu.choice("Poprzednia strona") do
          current_page -= 1 if current_page > 1

          list, pages = client.fetch_entries(current_page)
          print_entries(list)
        end

        menu.choice("Następna strona") do
          current_page += 1 if current_page < pages

          list, pages = client.fetch_entries(current_page)
          print_entries(list)
        end 

        menu.choice("Powrót do głównego menu") do
          throw :exit
        end
      end
    end
  end
end

def print_list(items, *fields)
  # find max length for each field; start with the field names themselves
  fields = items.first.class.column_names unless fields.any?
  max_len = Hash[*fields.map { |f| [f, f.to_s.length] }.flatten]
  items.each do |item|
    fields.each do |field|
      len = item.send(field).to_s.length
      max_len[field] = len if len > max_len[field]
    end
  end

  border = '+-' + fields.map { |f| '-' * max_len[f] }.join('-+-') + '-+'
  title_row = '| ' + fields.map { |f| sprintf("%-#{max_len[f]}s", f.to_s) }.join(' | ') + ' |'

  puts border
  puts title_row
  puts border

  items.each do |item|
    row = '| ' + fields.map { |f| sprintf("%-#{max_len[f]}s", item.send(f)) }.join(' | ') + ' |'
    puts row
  end

  puts border
  puts "#{items.length} rows in set\n"
end

def main
  config = load_config
  client = Ifin24::Client.new(config[:login], config[:password])

  catch :exit do
    loop do
      choose do |menu|
        menu.index = :letter
        menu.index_suffix = ") "
        menu.shell = true

        menu.choice("Dodaj wydatek") do
          add_entry(client)
        end

        menu.choice("Lista kont") do
          list_accounts(client)
        end

        menu.choice("Lista ostatnich transakcji") do
          list_entries(client)
        end

        menu.choice("Koniec") do
          throw :exit
        end
      end
    end
  end
end

main
