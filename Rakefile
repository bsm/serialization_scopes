require 'bundler'
Bundler.setup

require 'rake'
require 'rspec/mocks/version'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Default: run specs.'
task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "serialization_scopes"
    gemspec.summary = "Named scopes for ActiveRecord serialization methods (to_xml, to_json)"
    gemspec.description = "Adds named scopes for ActiveRecord serialization methods (to_xml, to_json)"
    gemspec.email = "dimitrij@blacksquaremedia.com"
    gemspec.homepage = "http://github.com/dim/serialization_scopes"
    gemspec.authors = ["Dimitrij Denissenko"]
    gemspec.add_runtime_dependency "activerecord", "> 2.5.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
end
