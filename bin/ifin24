#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup

require 'yaml'
require 'mechanize'
require 'highline/import'

require 'lib/ifin24'

def load_config
  file_name = File.join(ENV['HOME'], '.ifin24-client', 'config.yml')
  if File.exist?(file_name)
    YAML.load_file(file_name) rescue {}
  else
    puts "Nie odnaleziono pliku konfiguracyjnego: #{file_name}"
    exit
  end
end

def main
  config = load_config
  client = Ifin24::Client.new(config[:login], config[:password])
  console = Ifin24::Console.new(client)
  console.main_menu
end

main
