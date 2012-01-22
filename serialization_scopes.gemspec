# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "serialization_scopes"
  s.summary     = "Named scopes for ActiveRecord/ActiveResource serialization methods (to_xml, to_json)"
  s.description = "Adds named scopes for ActiveRecord/ActiveResource serialization methods (to_xml, to_json)"
  s.version     = File.read(File.expand_path("../VERSION", __FILE__)).strip

  s.authors     = ["Dimitrij Denissenko", "Evgeniy Dolzhenko"]
  s.email       = "info@blacksquaremedia.com"
  s.homepage    = "http://github.com/bsm/serialization_scopes"

  s.require_path = 'lib'
  s.files        = Dir['VERSION', 'README', 'lib/**/*', 'rails/**/*']

  s.add_dependency 'activemodel', '>= 3.0.0', '< 3.3.0'

  s.add_development_dependency 'activerecord', '>= 3.0.0', '< 3.3.0'
  s.add_development_dependency 'activeresource', '>= 3.0.0', '< 3.3.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3-ruby'
end
