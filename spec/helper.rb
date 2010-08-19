ENV["RAILS_ENV"] ||= 'test'
$: << File.join(File.dirname(__FILE__),'..', 'lib')

require 'rubygems'
require 'active_record'

require File.join(File.dirname(__FILE__),'..', 'rails', 'init.rb')
require 'spec/autorun'
require 'spec/mocks'

ActiveRecord::Base.stub(:establish_connection)

