module JSONAPI
  module Realizer
    class Action
      class Create < Action
        def initialize(payload:, headers:)
          @payload = payload
          @headers = headers
          @resource = resource_class.new(
            relation.new
          )
        end

        def call
          resource.model.tap do |model|
            resource_class.assign_attributes_via_call(model, {id: id}) if id
            resource_class.assign_attributes_via_call(model, attributes)
            resource_class.assign_attributes_via_call(model, relationships)
            resource_class.create_via_call(model)
          end
        end
      end
    end
  end
end
