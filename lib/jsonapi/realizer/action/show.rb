module JSONAPI
  module Realizer
    class Action
      class Show < Action
        def initialize(payload:, headers:, type:)
          @payload = payload
          @headers = headers
          @type = type
          @resource = resource_class.new(
            resource_class.find_via_call(relation, id)
          )
        end

        def call
          resource.model
        end
      end
    end
  end
end
