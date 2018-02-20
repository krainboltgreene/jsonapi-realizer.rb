module JSONAPI
  module Marshal
    class Create
      attr_reader :type
      attr_reader :data
      attr_reader :resource

      def initialize(payload:, headers:)
        @data = payload.fetch("data")
        @type = @data.fetch("type")
        @resource = resource_class.new(resource_class.model_class.new)
      end

      def call
        @resource.model.tap do |model|
          model.assign_attributes(id: id) if id
          model.assign_attributes(attributes.select(&@resource.method(:valid_attribute?)))
          model.assign_attributes(relationships.select(&@resource.method(:valid_relationship?)).transform_values(&@resource.method(:as_relationship)))
          model.create
        end
      end

      private def resource_class
        JSONAPI::Marshal.mapping.fetch(@type).resource_class
      end

      private def relationships
        data.fetch("relationships", {})
      end

      private def id
        data.fetch("id", nil)
      end

      private def attributes
        data.fetch("attributes", {})
      end
    end
  end
end
