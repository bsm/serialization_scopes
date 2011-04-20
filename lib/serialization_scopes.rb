module SerializationScopes
  extend ActiveSupport::Concern

  included do
    class_inheritable_accessor :serialization_scopes, :instance_reader => false, :instance_writer => false
  end

  module ClassMethods

    def serialization_scope(name, options = {})
      self.serialization_scopes ||= {}
      serialization_scopes[name.to_sym] = options
    end

    def scoped_serialization_options(options = {})
      options = options.try(:clone) || {}
      scopes  = (serialization_scopes[options[:scope]] || serialization_scopes[:default]) unless options[:scope] == false

      scopes.each do |key, defaults|
        options[key] = options[key] ? Resolver.scope(key, defaults, options[key]) : defaults
      end if scopes

      options
    end

  end

  module Resolver

    def self.scope(key, defaults, settings)
      defaults = Array.wrap(defaults).map(&:to_s)
      settings = Array.wrap(settings).map(&:to_s)

      case key
      when :except
        (settings + defaults).uniq
      when :only
        result = settings & defaults
        result.empty? ? defaults : result
      when :methods, :include
        settings & defaults
      else
        settings
      end
    end

  end

  def to_xml(options = {})
    super self.class.scoped_serialization_options(options)
  end

  def serializable_hash(options = {})
    super self.class.scoped_serialization_options(options)
  end

end

ActiveRecord::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveRecord::Base)

ActiveResource::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveResource::Base)
