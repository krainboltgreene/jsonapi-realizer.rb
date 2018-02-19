module JSONAPI
  module Marshal
    class Resource
      extend ActiveSupport::Concern

      def initialize(attributes:, relationships:)
        @model = model_class.new.tap do |model|
          model.assign_attributes(attributes.select(&method(:valid_attribute?)))
          model.assign_attributes(relationships.select(&method(:valid_relationship?)).map(&method(:as_relationship)))
        end
      end

      def relationship(name)
        relationships.public_send(name.to_sym)
      end

      def attribute(name)
        relationships.public_send(name.to_sym)
      end

      private def valid_attribute?(name, value)
        attributes.respond_to?(name.to_sym)
      end

      private def valid_relationship?(name, value)
        relationships.respond_to?(name.to_sym)
      end

      private def attributes
        configuration.attributes
      end

      private def relationships
        configuration.relationships
      end

      private def as_relationship(name, value)
        find_by_identifier(
          JSONAPI::Marshal.mapping.fetch(value.fetch("data").fetch("type")).model_class,
          value.fetch("data").fetch("id")
        )
      end

      private def model_class
        configuration.model_class
      end

      private def configuration
        self.class.configuration
      end

      def self.adapter(module)
        include(module)
      end

      def self.represents(type, class_name:)
        @configuration = JSONAPI::Marshal.register(self, class_name.constantize, type.to_s)
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
        @configuration
      end
    end
  end
end
