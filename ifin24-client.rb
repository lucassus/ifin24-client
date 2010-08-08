#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup

require 'yaml'
require 'mechanize'
require 'highline/import'

require 'lib/entry'
require 'lib/ifin24_client'

def get_entry(client)
  categories = client.fetch_categories
  accounts = client.fetch_accounts

  entry = Entry.new
  entry.title = ask('Nazwa')

  curr_date = Date.today
  entry.date = ask("Data (#{curr_date})")
  entry.date = curr_date.to_s if entry.date.empty?

  choose do |menu|
    menu.prompt = 'Wybierz rachunek'

    accounts.each do |name, id|
      menu.choice(name) do
        entry.account_name = name
        entry.account_id = id
      end
    end
  end

  sub_categories = {}
  choose do |menu|
    menu.prompt = 'Wybierz kategorię'

    categories.each do |name, sub|
      menu.choice(name) do
        entry.category_name = name
        sub_categories = sub
      end
    end
  end

  choose do |menu|
    menu.prompt = 'Wybierz podkategorię'

    sub_categories.each do |name, id|
      menu.choice(name) do
        entry.subcategory_name = name
        entry.subcategory_id = id
      end
    end
  end

  entry.amount = eval ask('Kwota')
  entry.tags = ask('Tagi')
  entry.note = ask('Opis')

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
  if agree("Dane poprawne?")
    puts "Wysyłanie danych..."
    client.send_entry(entry)
  end
end

def list(client)
  list = client.fetch_list
  pp list
end

def main
  config = load_config
  client = Ifin24Client.new(config[:login], config[:password])

  loop do
    choose do |menu|
      menu.index = :letter
      menu.index_suffix = ") "
      menu.shell = true

      menu.choice(:dodaj) do
        add_entry(client)
      end

      menu.choice(:lista) do
        list(client)
      end

      menu.choice(:koniec) do
        exit
      end
    end
  end
end

main
