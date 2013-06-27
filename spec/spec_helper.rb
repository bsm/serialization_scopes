ENV["RAILS_ENV"] ||= 'test'
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'active_resource'
require 'serialization_scopes'
require 'rspec'
require File.expand_path('../helper_models', __FILE__)

ActiveRecord::Base.include_root_in_json = false
ActiveResource::Base.include_root_in_json = true
