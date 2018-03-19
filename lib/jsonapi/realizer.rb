require "ostruct"
require "active_support/concern"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/string"

module JSONAPI
  module Realizer
    require_relative "realizer/version"
    require_relative "realizer/error"
    require_relative "realizer/action"
    require_relative "realizer/adapter"
    require_relative "realizer/resource"

    def self.register(resource_class:, model_class:, adapter:, type:)
      @mapping ||= Set.new
      @mapping << OpenStruct.new({
        resource_class: resource_class,
        model_class: model_class,
        adapter: adapter,
        type: type.dasherize,
        attributes: OpenStruct.new({}),
        relationships: OpenStruct.new({})
       })
    end

    def self.resource_mapping
      @mapping.index_by(&:resource_class)
    end

    def self.type_mapping
      @mapping.index_by(&:type)
    end

    def self.create(payload, headers:)
      enact(Action::Create.new(payload: payload, headers: headers))
    end

    def self.update(payload, headers:)
      enact(Action::Update.new(payload: payload, headers: headers))
    end

    def self.show(payload, headers:, type:)
      enact(Action::Show.new(payload: payload, headers: headers, type: type))
    end

    def self.index(payload, headers:, type:)
      enact(Action::Index.new(payload: payload, headers: headers, type: type))
    end

    private_class_method def self.enact(action)
      action.tap(&:call)
    end
  end
end
