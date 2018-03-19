module JSONAPI
  module Realizer
    class Action
      class Index < Action
        attr_accessor :resources

        def initialize(payload:, headers:, type:)
          @payload = payload
          @headers = headers
          @type = type

          super(payload: payload, headers: headers)

          @resources = adapter.find_many_via_call(relation).map(&resource_class.method(:new))
        end

        def models
          resources.map(&:model)
        end

        private def data
          payload["data"]
        end

        private def type
          @type.to_s.dasherize if @type
        end
      end
    end
  end
end
