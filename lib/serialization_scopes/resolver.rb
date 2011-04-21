module SerializationScopes
  module Resolver
    extend self

    def scope(key, defaults, settings)
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
end
