module JSONAPI
  module Realizer
    class Action
      class Index < Action
        attr_accessor :resources

        def initialize(payload:, headers:, type:)
          @payload = payload
          @headers = headers
          @type = type
          @resources = adapter.find_many_via_call(relation).map(&resource_class.method(:new))
        end

        def models
          resources.map(&:model)
        end
      end
    end
  end
end
