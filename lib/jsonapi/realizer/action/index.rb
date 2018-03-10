module JSONAPI
  module Realizer
    class Action
      class Index < Action
        def initialize(payload:, headers:, type:)
          @payload = payload
          @headers = headers
          @type = type
          @resources = resource_class.find_many_via_call(relation).map(&resource_class.method(:new))
        end

        def call
          resources.map(&:model)
        end
      end
    end
  end
end
