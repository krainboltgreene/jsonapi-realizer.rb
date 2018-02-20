require "active_support/concern"
require "ostruct"

module JSONAPI
  module Realizer
    require_relative "realizer/version"
    require_relative "realizer/create"
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
  end
end
