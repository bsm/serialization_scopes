# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.1'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "serialization_scopes"
  s.summary     = "Named scopes for ActiveRecord/ActiveResource serialization methods (to_xml, to_json)"
  s.description = "Adds named scopes for ActiveRecord/ActiveResource serialization methods (to_xml, to_json)"
  s.version     = "1.5.0"

  s.authors     = ["Dimitrij Denissenko", "Evgeniy Dolzhenko"]
  s.email       = "info@blacksquaremedia.com"
  s.homepage    = "http://github.com/bsm/serialization_scopes"

  s.require_path = 'lib'
  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")

  s.add_dependency 'activemodel', '>= 4.1.0'
  s.add_development_dependency 'activerecord', '>= 4.1.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
end
