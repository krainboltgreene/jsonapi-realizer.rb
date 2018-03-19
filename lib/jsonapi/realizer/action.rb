module JSONAPI
  module Realizer
    class Action
      require_relative "action/create"
      require_relative "action/update"
      require_relative "action/show"
      require_relative "action/index"

      attr_reader :payload
      attr_reader :headers

      def initialize(payload:, headers:)
        raise Error::MissingAcceptHeader unless headers.key?("Accept")
        raise Error::InvalidAcceptHeader unless headers.fetch("Accept") == "application/vnd.api+json"
        raise Error::TooManyRootProperties if payload.key?("data") && payload.key?("errors")
        raise Error::IncludeWithoutDataProperty if payload.key?("include") && !payload.key?("data")
        raise Error::MalformedDataRootProperty unless payload.key?("data") && data.kind_of?(Array) || data.kind_of?(Hash) || data.nil?
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
        if fields.any?
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
        payload.fetch("data")
      end

      private def type
        data["type"].to_s.dasherize if data
      end

      private def attributes
        data.
          fetch("attributes", {}).
          transform_keys(&:underscore).
          select(&resource_class.method(:valid_attribute?)) if data
      end

      private def relationships
        data.
          fetch("relationships", {}).
          transform_keys(&:underscore).
          select(&resource_class.method(:valid_relationship?)).
          transform_values(&method(:as_relationship)) if data
      end

      private def as_relationship(value)
        data = value.fetch("data")
        mapping = JSONAPI::Realizer.type_mapping.fetch(data.fetch("type"))
        mapping.adapter.find_via_call(
          mapping.model_class,
          data.fetch("id")
        )
      end

      def includes
        return [] unless payload.key?("include")

        payload.
          fetch("include").
          # "carts.cart-items,carts.cart-items.product,carts.billing-information,payments"
          split(/\s*,\s*/).
          # ["carts.cart-items", "carts.cart-items.product", "carts.billing-information", "payments"]
          map { |path| path.gsub("-", "_") }.
          # ["carts.cart_items", "carts.cart_items.product", "carts.billing_information", "payments"]
          map { |path| path.split(".") }.
          # [["carts", "cart_items"], ["carts", "cart_items", "product"], ["carts", "billing_information"], ["payments"]]
          select do |chain|
            # ["carts", "cart_items"]
            chain.reduce(resource_class) do |last_resource_class, key|
              break unless last_resource_class

              JSONAPI::Realizer.type_mapping.fetch(last_resource_class.relationship(key).as).resource_class if last_resource_class.valid_includes?(key)
            end
          end
          # [["carts", "cart_items", "product"], ["payments"]]
      end

      def fields
        return [] unless payload.key?("fields")

        payload.
          fetch("fields").
          # "title,active-photographer.email,active-photographer.posts.title"
          split(/\s*,\s*/).
          # ["title", "active-photographer.email", "active-photographer.posts.title"]
          map { |path| path.gsub("-", "_") }.
          # ["title", "active_photographer.email", "active_photographer.posts.title"]
          map { |path| path.split(".") }.
          # [["title"], ["active_photographer", "email"], ["active_photographer", "posts", "title"]]
          select do |chain|
            # ["active_photographer", "email"]
            chain.reduce(resource_class) do |last_resource_class, key|
              break unless last_resource_class

              if last_resource_class.valid_includes?(key)
                JSONAPI::Realizer.type_mapping.fetch(last_resource_class.relationship(key).as).resource_class
              elsif last_resource_class.valid_sparse_field?(key)
                last_resource_class
              end
            end
          end
          # [["title"], ["active_photographer", "email"]]
      end

      private def configuration
        JSONAPI::Realizer.type_mapping.fetch(type)
      end
    end
  end
end
