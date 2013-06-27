require 'serialization_scopes/resolver'
require 'serialization_scopes/responder'
require 'active_support/concern'

module SerializationScopes
  extend ActiveSupport::Concern

  module ClassMethods

    def serialization_scope(name, options = {})
      include InstanceExtensions unless included_modules.include?(InstanceExtensions)
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

    protected

      def serialization_scopes
        @_serialization_scopes ||= superclass.respond_to?(:serialization_scopes, true) ? superclass.send(:serialization_scopes).clone : {}
      end

  end

  module InstanceExtensions

    def to_xml(options = {})
      super self.class.scoped_serialization_options(options)
    end

    def serializable_hash(options = {})
      super self.class.scoped_serialization_options(options)
    end

    private

      # Propagate scope to includes
      def serializable_add_includes(options = {}) #:nodoc:
        super do |association, records, opts|
          yield association, records, opts.merge(:scope => options[:scope])
        end
      end

  end
end

ActiveRecord::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveRecord::Base)

ActiveResource::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveResource::Base)
