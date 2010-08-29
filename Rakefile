# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ifin24-client"
    gem.summary = %Q{Console for iFIN24}
    gem.description = %Q{Console for iFIN24}
    gem.email = "lucassus@gmail.com"
    gem.homepage = "http://github.com/lucassus/ifin24-client"
    gem.authors = ["Łukasz Bandzarewicz"]
    
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "mocha"

    gem.add_dependency "mechanize"
    gem.add_dependency "highline"
    gem.add_dependency "rainbow"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ifin24-client.1 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
