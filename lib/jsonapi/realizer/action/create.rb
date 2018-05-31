module JSONAPI
  module Realizer
    class Action
      class Create < Action
        attr_accessor :resource

        def initialize(payload:, headers:, scope: nil)
          raise Error::MissingContentTypeHeader unless headers.key?("Content-Type")
          raise Error::InvalidContentTypeHeader, given: headers.fetch("Content-Type"), accepted: JSONAPI::MEDIA_TYPE unless headers.fetch("Content-Type") == JSONAPI::MEDIA_TYPE

          super(payload: payload, headers: headers, scope: scope)

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
