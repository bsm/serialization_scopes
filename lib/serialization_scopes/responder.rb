module SerializationScopes
  module Responder

    def display(resource, given_options={})
      if controller.respond_to?(:serialization_scope)
        given_options.reverse_merge! :scope => controller.send(:serialization_scope)
      end
      super
    end

  end
end