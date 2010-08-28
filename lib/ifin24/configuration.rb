require 'singleton'
require 'yaml'

class Ifin24::Configuration
  include Singleton

  CONFIG_FILE_NAME = File.join(ENV['HOME'], '.ifin24-client', 'config.yml')

  attr_reader :config

  def initialize
    @config = {}
    
    if File.exist?(CONFIG_FILE_NAME)
      @config = YAML.load_file(CONFIG_FILE_NAME) rescue {}
    end
  end

  def [](index)
    @config[index]
  end
end
