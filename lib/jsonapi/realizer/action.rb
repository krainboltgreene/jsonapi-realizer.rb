module JSONAPI
  module Realizer
    class Action
      require_relative "action/create"
      require_relative "action/update"
      require_relative "action/show"
      require_relative "action/index"

      attr_reader :payload
      attr_reader :resource
      attr_reader :resources

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
        JSONAPI::Realizer.mapping.fetch(type.to_s).resource_class
      end

      private def relationships
        data.fetch("relationships", {})
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
        data.fetch("attributes", {})
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
    end
  end
end
