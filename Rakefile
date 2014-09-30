require 'bundler'
require 'bundler/gem_tasks'
Bundler.setup

require 'rake'
require 'rspec/mocks/version'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Default: run specs.'
task :default => :spec
