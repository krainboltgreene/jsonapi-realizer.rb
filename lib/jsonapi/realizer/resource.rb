module JSONAPI
  module Realizer
    module Resource
      extend ActiveSupport::Concern

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

      class_methods do
        def attribute(name)
          attributes.public_send(name.to_sym)
        end

        def relationship(name)
          relationships.public_send(name.to_sym)
        end

        def valid_attribute?(name, value)
          attributes.respond_to?(name.to_sym)
        end

        def valid_relationship?(name, value)
          relationships.respond_to?(name.to_sym)
        end

        def valid_sparse_field?(name)
          attribute(name).fetch(:selectable)
        end

        def valid_includes?(name)
          relationship(name).fetch(:includable)
        end

        def has(name, selectable: true)
          attributes.public_send("#{name}=", OpenStruct.new({name: name, selectable: selectable}))
        end

        def has_related(name, as: name, includable: true)
          relationships.public_send("#{name}=", OpenStruct.new({name: name, as: as, includable: includable}))
        end

        def has_one(name, as: name, includable: true)
          has_related(name, as: name, includable: includable)
        end

        def has_many(name, as: name, includable: true)
          has_related(name, as: name, includable: includable)
        end

        def adapter
          configuration.adapter
        end

        def attributes
          configuration.attributes
        end

        def relationships
          configuration.relationships
        end

        def model_class
          configuration.model_class
        end

        def register(type, class_name:, adapter:)
          JSONAPI::Realizer.register(
            resource_class: self,
            model_class: class_name.constantize,
            adapter: JSONAPI::Realizer::Adapter.new(adapter),
            type: type.to_s
          )
        end

        def configuration
          JSONAPI::Realizer.resource_mapping.fetch(self)
        end
      end
    end
  end
end
