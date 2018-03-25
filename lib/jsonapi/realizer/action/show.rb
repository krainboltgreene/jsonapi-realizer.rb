module JSONAPI
  module Realizer
    class Action
      class Show < Action
        attr_accessor :resource

        def initialize(payload:, headers:, scope: nil, type:)
          @type = type

          super(payload: payload, headers: headers, scope: scope)

          @resource = resource_class.new(adapter.find_via_call(relation, id))
        end

        def model
          resource.model
        end

        private def data
          payload["data"]
        end

        private def type
          @type.to_s.dasherize if @type
        end

        private def id
          return data.fetch("id", nil) if data

          payload.fetch("id", nil)
        end
      end
    end
  end
end
