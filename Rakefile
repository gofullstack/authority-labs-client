require 'rubygems'
require 'fileutils'

begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with gem install jeweler"
end

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "authority-labs-client"
  gemspec.description = "A Ruby client for the Authority Labs (http://authoritylabs.com/) API."
  gemspec.summary = "Get domain and keyword data from Authority Labs."
  gemspec.email = "support@cramerdev.com"
  gemspec.homepage = "http://cramerdev.com/"
  gemspec.authors = ["Cramer Development"]
  gemspec.add_dependency('active_support', '>= 2.0.2')
  gemspec.add_dependency('active_resource', '>= 2.0.2')
  gemspec.version = "0.0.1"
end

require 'rake/testtask'
Rake::TestTask.new

task :default => :test

