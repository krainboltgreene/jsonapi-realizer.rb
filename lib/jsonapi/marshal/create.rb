module JSONAPI
  module Marshal
    class Create
      attr_reader :type
      attr_reader :data
      attr_reader :resource

      def initialize(payload:, headers:)
        @data = payload.fetch("data")
        @type = @data.fetch("type")
        @resource = resource_class.new(attributes: attributes, relationships: relationships)
      end

      def call
        @resource.model
      end

      private def resource_class
        JSONAPI::Marshal.mapping.fetch(@type).resource_class
      end

      private def relationships
        data.fetch("relationships", {})
      end

      private def attributes
        data.fetch("attributes", {})
      end
    end
  end
end
