module JSONAPI
  module Realizer
    class Action
      class Create < Action
        attr_accessor :resource

        def initialize(payload:, headers:)
          @payload = payload
          @headers = headers
          @resource = resource_class.new(relation.new)
        end

        def call
          adapter.assign_attributes_via_call(resource.model, {id: id}) if id
          adapter.assign_attributes_via_call(resource.model, attributes)
          adapter.assign_relationships_via_call(resource.model, relationships)
          adapter.create_via_call(resource.model)
        end

        def model
          resource.model
        end
      end
    end
  end
end
