module JSONAPI
  module Realizer
    class Action
      require_relative "action/create"
      require_relative "action/update"

      attr_reader :payload
      attr_reader :resource

      def initialize
        raise NoMethodError, "must implement this function"
      end

      def call
        raise NoMethodError, "must implement this function"
      end

      private def model_class
        resource_class.model_class
      end

      private def resource_class
        JSONAPI::Realizer.mapping.fetch(type).resource_class
      end

      private def relationships
        data.fetch("relationships", {})
      end

      private def relation
        relation_after_fields(
          relation_after_inclusion(
            model_class
          )
        )
      end

      private def data
        payload.fetch("data", {})
      end

      private def id
        data.fetch("id", nil)
      end

      private def type
        data.fetch("type")
      end

      private def attributes
        data.fetch("attributes", {})
      end
    end
  end
end
