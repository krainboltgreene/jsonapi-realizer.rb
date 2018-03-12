module JSONAPI
  module Realizer
    class Resource
      attr_reader :model

      def initialize(model)
        @model = model
      end

      private def attribute(name)
        attributes.public_send(name.to_sym)
      end

      private def relationship(name)
        relationships.public_send(name.to_sym)
      end

      private def attributes
        configuration.attributes
      end

      private def relationships
        configuration.relationships
      end

      private def model_class
        configuration.model_class
      end

      private def configuration
        self.class.configuration
      end

      def self.attribute(name)
        attributes.public_send(name.to_sym)
      end

      def self.relationship(name)
        relationships.public_send(name.to_sym)
      end

      def self.valid_attribute?(name, value)
        attributes.respond_to?(name.to_sym)
      end

      def self.valid_relationship?(name, value)
        relationships.respond_to?(name.to_sym)
      end

      def self.valid_sparse_field?(name)
        attribute(name).fetch(:selectable)
      end

      def self.valid_includes?(name)
        relationship(name).fetch(:includable)
      end

      def self.has(name, selectable: true)
        attributes.public_send("#{name}=", OpenStruct.new({name: name, selectable: selectable}))
      end

      def self.has_related(name, as: name, includable: true)
        relationships.public_send("#{name}=", OpenStruct.new({name: name, as: as, includable: includable}))
      end

      def self.has_one(name, as: name, includable: true)
        has_related(name, as: name, includable: includable)
      end

      def self.has_many(name, as: name, includable: true)
        has_related(name, as: name, includable: includable)
      end

      def self.adapter
        configuration.adapter
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

      def self.register(type, class_name:, adapter:)
        JSONAPI::Realizer.register(
          resource_class: self,
          model_class: class_name.constantize,
          adapter: JSONAPI::Realizer::Adapter.new(adapter),
          type: type.to_s
        )
      end

      def self.configuration
        JSONAPI::Realizer.resource_mapping.fetch(self)
      end
    end
  end
end
