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
      name   = options.delete(:scope)
      scopes = name.present? && serialization_scopes[name.to_sym] ? serialization_scopes[name.to_sym] : serialization_scopes[:default]
      scopes.each do |key, values|
        options[key] ||= Array(values)
        options[key] = Array(options[key]) & Array(values)
      end if scopes
      options
    end
  end

  def to_xml(options = {})
    super self.class.scoped_serialization_options(options)
  end

  def to_json(options = {})
    super self.class.scoped_serialization_options(options)
  end

end
