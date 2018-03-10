module JSONAPI
  module Realizer
    class Action
      class Update < Action
        def initialize(payload:, headers:)
          @payload = payload
          @headers = headers
          @resource = resource_class.new(
            resource_class.find_via_call(relation, id)
          )
        end

        def call
          resource.model.tap do |model|
            resource_class.assign_attributes_via_call(model, attributes)
            resource_class.assign_attributes_via_call(model, relationships)
            resource_class.update_via_call(model)
          end
        end
      end
    end
  end
end
