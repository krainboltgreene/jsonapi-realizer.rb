module JSONAPI
  module Realizer
    class Action
      class Update < Action
        attr_accessor :resource

        def initialize(payload:, headers:)
          @payload = payload
          @headers = headers

          raise Error::MissingContentTypeHeader unless headers.key?("Content-Type")
          raise Error::InvalidContentTypeHeader unless headers.fetch("Content-Type") == "application/vnd.api+json"

          super(payload: payload, headers: headers)

          @resource = resource_class.new(adapter.find_via_call(relation, id))

          raise Error::MissingRootProperty unless payload.key?("data") || payload.key?("errors") || payload.key?("meta")
          raise Error::MissingTypeResourceProperty if payload.key?("data") && data.kind_of?(Hash) && !data.key?("type")
          raise Error::MissingTypeResourceProperty if payload.key?("data") && data.kind_of?(Array) && !data.all? {|resource| resource.key?("type")}
        end

        def call
          adapter.assign_attributes_via_call(resource.model, attributes)
          adapter.assign_relationships_via_call(resource.model, relationships)
          adapter.update_via_call(resource.model)
        end

        def model
          resource.model
        end

        private def id
          return data.fetch("id", nil) if data

          payload.fetch("id", nil)
        end
      end
    end
  end
end
