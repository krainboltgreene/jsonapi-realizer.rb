module JSONAPI
  module Marshal
    class Resource
      extend ActiveSupport::Concern

      attr_reader :model

      def initialize(model)
        @model = model
      end

      def relationship(name)
        relationships.public_send(name.to_sym)
      end

      def attribute(name)
        relationships.public_send(name.to_sym)
      end

      private def attributes
        configuration.attributes
      end

      private def relationships
        configuration.relationships
      end

      private def as_relationship(value)
        data = value.fetch("data")
        mapping = JSONAPI::Marshal.mapping.fetch(data.fetch("type"))
        mapping.resource_class.find_via_call(
          mapping.model_class,
          data.fetch("id")
        )
      end

      private def model_class
        configuration.model_class
      end

      private def configuration
        self.class.configuration
      end

      def valid_attribute?(name, value)
        attributes.respond_to?(name.to_sym)
      end

      def valid_relationship?(name, value)
        relationships.respond_to?(name.to_sym)
      end

      def self.represents(type, class_name:)
        @configuration = JSONAPI::Marshal.register(self, class_name.constantize, type.to_s)
      end

      def self.find_via(&finder)
        @find_via_call = finder
      end

      def self.find_via_call(model_class, id)
        @find_via_call.call(model_class, id)
      end

      def self.has_one(name, as: name)
        relationships.public_send("#{name}=", OpenStruct.new({name: name, as: as}))
      end

      def self.has(name)
        attributes.public_send("#{name}=", OpenStruct.new({name: name}))
      end

      def self.relationship(name)
        relationships.public_send(name.to_sym)
      end

      def self.attribute(name)
        relationships.public_send(name.to_sym)
      end

      def self.attributes
        configuration.attributes
      end

      def self.relationships
        configuration.relationships
      end

      def self.model_class
        configuration.model_class
      end

      def self.configuration
        if @configuration
          @configuration
        else
          raise ArgumentError, "you need to have the resource configured"
        end
      end
    end
  end
end
