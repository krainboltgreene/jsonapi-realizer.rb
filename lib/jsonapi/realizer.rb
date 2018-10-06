require("ostruct")
require("active_support/concern")
require("active_support/core_ext/enumerable")
require("active_support/core_ext/string")

module JSONAPI
  MEDIA_TYPE = "application/vnd.api+json" unless const_defined?("MEDIA_TYPE")

  module Realizer
    require_relative "realizer/action"
    require_relative("realizer/version")
    require_relative("realizer/error")

    def self.create(payload, headers:, scope: nil)
      enact(Action::Create.new(payload: payload, headers: headers, scope: scope))
    end

    def self.update(payload, headers:, scope: nil)
      enact(Action::Update.new(payload: payload, headers: headers, scope: scope))
    end

    def self.show(payload, headers:, type:, scope: nil)
      enact(Action::Show.new(payload: payload, headers: headers, type: type, scope: scope))
    end

    def self.index(payload, headers:, type:, scope: nil)
      enact(Action::Index.new(payload: payload, headers: headers, type: type, scope: scope))
    end
    require_relative("realizer/adapter")
    require_relative("realizer/resource")

    private_class_method def self.enact(action)
      action.tap(&:call)
    end
  end
end
