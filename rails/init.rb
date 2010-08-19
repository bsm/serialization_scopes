require 'serialization_scopes'
ActiveRecord::Base.class_eval do
  include SerializationScopes
end