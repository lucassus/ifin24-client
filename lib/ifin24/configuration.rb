require 'singleton'
require 'yaml'

class Ifin24::Configuration
  include Singleton

  attr_reader :config

  def initialize
    @config = {}
    
    config_file_name = File.join(ENV['HOME'], '.ifin24-client', 'config.yml')
    if File.exist?(config_file_name)
      @config = YAML.load_file(config_file_name) rescue {}
    end
  end

  def [](index)
    @config[index]
  end
end
