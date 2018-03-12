module JSONAPI
  module Realizer
    class Action
      require_relative "action/create"
      require_relative "action/update"
      require_relative "action/show"
      require_relative "action/index"

      attr_reader :payload

      def initialize
        raise NoMethodError, "must implement this function"
      end

      def call; end

      private def model_class
        resource_class.model_class
      end

      private def resource_class
        configuration.resource_class
      end

      private def adapter
        configuration.adapter
      end

      private def relation_after_inclusion(relation)
        if includes.any?
          resource_class.include_via_call(relation, includes)
        else
          relation
        end
      end

      private def relation_after_fields(relation)
        if includes.any?
          resource_class.sparse_fields_call(relation, fields)
        else
          relation
        end
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
        data.fetch("id", nil) || payload.fetch("id", nil)
      end

      private def type
        @type || data.fetch("type")
      end

      private def attributes
        data.
          fetch("attributes", {}).
          transform_keys(&:underscore).
          select(&resource_class.method(:valid_attribute?))
      end

      private def relationships
        data.
          fetch("relationships", {}).
          transform_keys(&:underscore).
          select(&resource_class.method(:valid_relationship?)).
          transform_values(&method(:as_relationship))
      end

      private def as_relationship(value)
        data = value.fetch("data")
        mapping = JSONAPI::Realizer.type_mapping.fetch(data.fetch("type"))
        mapping.adapter.find_via_call(
          mapping.model_class,
          data.fetch("id")
        )
      end

      private def includes
        payload.
          fetch("include", []).
          # "carts.cart-items,carts.cart-items.product,carts.billing-information,payments"
          map { |path| path.split(/\s*,\s*/) }.
          # ["carts.cart-items", "carts.cart-items.product", "carts.billing-information", "payments"]
          map { |path| path.gsub("-", "_") }.
          # ["carts.cart_items", "carts.cart_items.product", "carts.billing_information", "payments"]
          map { |path| path.split(".") }.
          # [["carts", "cart_items"], ["carts", "cart_items", "product"], ["carts", "billing_information"], ["payments"]]
          select(&resource_class.method(:valid_includes?))
      end

      private def fields
        payload.
          fetch("fields", []).
          split(/\s*,\s*/).
          select(&resource_class.method(:valid_sparse_field?))
      end

      private def configuration
        JSONAPI::Realizer.type_mapping.fetch(type.to_s)
      end
    end
  end
end
