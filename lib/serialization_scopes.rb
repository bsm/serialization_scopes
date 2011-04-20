module SerializationScopes
  extend ActiveSupport::Concern

  included do
    class_attribute :serialization_scopes, :instance_writer => false
    alias_method_chain :to_xml, :scopes
    alias_method_chain :as_json, :scopes
  end

  module ClassMethods

    def serialization_scope(name, options = {})
      self.serialization_scopes ||= {}
      serialization_scopes[name.to_sym] = options
    end

    def scoped_serialization_options(options = {})
      options = options.try(:clone) || {}
      name    = options[:scope].try(:to_sym)
      scopes  = name.present? && serialization_scopes.key?(name) ? serialization_scopes[name] : serialization_scopes[:default]

      scopes.each do |key, defaults|
        options[key] = options[key] ? Resolver.scope(key, defaults, options[key]) : defaults
      end if scopes

      options
    end

  end

  module Resolver

    def self.scope(key, defaults, settings)
      defaults = Array.wrap(defaults)
      settings = Array.wrap(settings)

      case key
      when :except
        (settings + defaults).uniq
      when :only, :methods, :include
        settings & defaults
      else
        settings
      end
    end

  end

  def to_xml_with_scopes(options = {})
    to_xml_without_scopes self.class.scoped_serialization_options(options)
  end

  def as_json_with_scopes(options = {})
    as_json_without_scopes self.class.scoped_serialization_options(options)
  end

end

ActiveRecord::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveRecord::Base)

ActiveResource::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveResource::Base)
