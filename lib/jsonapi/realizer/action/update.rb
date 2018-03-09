module JSONAPI
  module Realizer
    class Action
      class Update < Action
        def initialize(payload:, headers:)
          @data = payload.fetch("data")
          @resource = resource_class.new(
            resource_class.find_via_call(relation, id)
          )
        end

        def call
          @resource.model.tap do |model|
            resource_class.write_attributes_via_call(model, attributes.select(&resource.method(:valid_attribute?)))
            resource_class.write_attributes_via_call(model, relationships.select(&resource.method(:valid_relationship?)).transform_values(&resource.method(:as_relationship)))
            resource_class.save_via_call(model)
          end
        end
      end
    end
  end
end
