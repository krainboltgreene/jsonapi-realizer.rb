module JSONAPI
  module Realizer
    class Action
      class Update < Action
        attr_accessor :resource

        def initialize(payload:, headers:)
          @payload = payload
          @headers = headers
          @resource = resource_class.new(
            adapter.find_via_call(relation, id)
          )
        end

        def call
          adapter.assign_attributes_via_call(resource.model, attributes)
          adapter.assign_relationships_via_call(resource.model, relationships)
          adapter.update_via_call(resource.model)
        end

        def model
          resource.model
        end
      end
    end
  end
end
