require "ostruct"
require "active_support/concern"

module JSONAPI
  module Realizer
    require_relative "realizer/version"
    require_relative "realizer/action"
    require_relative "realizer/adapter"
    require_relative "realizer/resource"

    def self.register(resource_class, model_class, type)
      @mapping ||= {}
      @mapping[type] = OpenStruct.new({
        model_class: model_class,
        type: type,
        resource_class: resource_class,
        attributes: OpenStruct.new({}),
        relationships: OpenStruct.new({})
       })
    end

    def self.mapping
      @mapping
    end

    def self.create(payload, headers:)
      Create.new(payload: payload, headers: headers).call
    end

    def self.update(payload, headers:)
      Update.new(payload: payload, headers: headers).call
    end

    def self.show(payload, headers:, type:)
      Show.new(payload: payload, headers: headers, type: type).call
    end

    def self.index(payload, headers:, type:)
      Index.new(payload: payload, headers: headers, type: type).call
    end
  end
end
