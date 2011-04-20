ENV["RAILS_ENV"] ||= 'test'
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'

# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end

require 'active_record'
require 'active_resource'
require 'serialization_scopes'
require 'rspec'

RSpec.configure do |c|
  c.mock_with :rspec
end

ActiveRecord::Base.include_root_in_json = false
