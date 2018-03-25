module JSONAPI
  module Realizer
    class Action
      class Create < Action
        attr_accessor :resource

        def initialize(payload:, headers:)
          @payload = payload
          @headers = headers

          raise Error::MissingContentTypeHeader unless headers.key?("Content-Type")
          raise Error::InvalidContentTypeHeader unless headers.fetch("Content-Type") == "application/vnd.api+json"

          super(payload: payload, headers: headers)

          @resource = resource_class.new(relation.new)

          raise Error::MissingRootProperty unless payload.key?("data") || payload.key?("errors") || payload.key?("meta")
          raise Error::MissingTypeResourceProperty if payload.key?("data") && data.kind_of?(Hash) && !data.key?("type")
          raise Error::MissingTypeResourceProperty if payload.key?("data") && data.kind_of?(Array) && !data.all? {|resource| resource.key?("type")}
        end

        def call
          adapter.assign_attributes_via_call(resource.model, {id: id}) if id
          adapter.assign_attributes_via_call(resource.model, attributes)
          adapter.assign_relationships_via_call(resource.model, relationships)
        end

        def model
          resource.model
        end

        private def id
          payload.fetch("id", nil)
        end
      end
    end
  end
end
