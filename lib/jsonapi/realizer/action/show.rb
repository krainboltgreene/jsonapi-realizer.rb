module JSONAPI
  module Realizer
    class Action
      class Show < Action

        attr_accessor :resource

        def initialize(payload:, headers:, type:)
          @payload = payload
          @headers = headers
          @type = type
          @resource = resource_class.new(adapter.find_via_call(relation, id))
        end

        def model
          resource.model
        end
      end
    end
  end
end
