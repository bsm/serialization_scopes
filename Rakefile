require 'bundler'
Bundler.setup

require 'rake'
require 'spec/rake/spectask'

desc 'Run specs.'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ["-c"]
end

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
    gemspec.add_runtime_dependency "activerecord", ">= 2.3.0", '< 3.0.0'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
end
