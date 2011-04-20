module SerializationScopes

  def self.included(base)
    base.extend ClassMethods
    base.class_inheritable_reader    :serialization_scopes
    base.write_inheritable_attribute :serialization_scopes, {}
  end

  module ClassMethods
    def serialization_scope(name, options = {})
      serialization_scopes[name.to_sym] = options
    end

    def scoped_serialization_options(options = {})
      options ||= {}
      name    = (options || {})[:scope]
      scopes  = name.present? && serialization_scopes[name.to_sym] ? serialization_scopes[name.to_sym] : serialization_scopes[:default]
      options = options.dup
      scopes.each do |key, scope_options|
        custom_options = options[key]
        options[key] = if key == :except
          custom_options ? (Array.wrap(custom_options) + Array.wrap(scope_options)).uniq : Array.wrap(scope_options)
        elsif [:only, :methods, :include].include?(key)
          custom_options ? Array.wrap(custom_options) & Array.wrap(scope_options) : Array.wrap(scope_options)
        else
          custom_options ? custom_options : scope_options
        end
      end if scopes
      options
    end

  end

  def to_xml(options = {})
    super self.class.scoped_serialization_options(options)
  end

  def as_json(options = {})
    super self.class.scoped_serialization_options(options)
  end

end

ActiveRecord::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveRecord::Base)

ActiveResource::Base.class_eval do
  include SerializationScopes
end if defined?(ActiveResource::Base)
