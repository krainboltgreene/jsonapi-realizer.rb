# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Action
      require_relative "action/create"
      require_relative "action/update"
      require_relative "action/show"
      require_relative "action/index"
      require_relative "action/destroy"

      attr_reader :payload
      attr_reader :headers

      def initialize(payload:, headers:, scope: nil)
        @scope = scope
        @headers = headers
        @payload = payload

        raise Error::MissingAcceptHeader unless @headers.key?("Accept")
        raise Error::InvalidAcceptHeader, given: @headers.fetch("Accept"), wanted: JSONAPI::MEDIA_TYPE unless @headers.fetch("Accept") == JSONAPI::MEDIA_TYPE
        raise Error::IncludeWithoutDataProperty if @payload.key?("include") && !@payload.key?("data")
        raise Error::MalformedDataRootProperty, given: data if @payload.key?("data") && !(data.is_a?(Array) || data.is_a?(Hash) || data.nil?)
      end

      def call; end

      def relation
        relation_after_fields(
          relation_after_inclusion(
            @scope || model_class
          )
        )
      end

      def includes
        return [] if payload.blank?
        return [] unless payload.key?("include")

        payload
          .fetch("include").
          # "carts.cart-items,carts.cart-items.product,carts.billing-information,payments"
          split(/\s*,\s*/).
          # ["carts.cart-items", "carts.cart-items.product", "carts.billing-information", "payments"]
          map { |path| path.tr("-", "_") }.
          # ["carts.cart_items", "carts.cart_items.product", "carts.billing_information", "payments"]
          map { |path| path.split(".") }.
          # [["carts", "cart_items"], ["carts", "cart_items", "product"], ["carts", "billing_information"], ["payments"]]
          select do |chain|
            # ["carts", "cart_items"]
            chain.reduce(resource_class) do |last_resource_class, key|
              break unless last_resource_class

              JSONAPI::Realizer::Resource.type_mapping.fetch(last_resource_class.relationship(key).as).resource_class if last_resource_class.valid_includes?(key)
            end
          end
        # [["carts", "cart_items", "product"], ["payments"]]
      end

      def fields
        return [] if payload.blank?
        return [] unless payload.key?("fields")

        payload
          .fetch("fields").
          # "title,active-photographer.email,active-photographer.posts.title"
          split(/\s*,\s*/).
          # ["title", "active-photographer.email", "active-photographer.posts.title"]
          map { |path| path.tr("-", "_") }.
          # ["title", "active_photographer.email", "active_photographer.posts.title"]
          map { |path| path.split(".") }.
          # [["title"], ["active_photographer", "email"], ["active_photographer", "posts", "title"]]
          select do |chain|
            # ["active_photographer", "email"]
            chain.reduce(resource_class) do |last_resource_class, key|
              break unless last_resource_class

              if last_resource_class.valid_includes?(key)
                JSONAPI::Realizer::Resource.type_mapping.fetch(last_resource_class.relationship(key).as).resource_class
              elsif last_resource_class.valid_sparse_field?(key)
                last_resource_class
              end
            end
          end
        # [["title"], ["active_photographer", "email"]]
      end

      private

      def model_class
        resource_class&.model_class
      end

      def resource_class
        configuration&.resource_class
      end

      def adapter
        configuration&.adapter
      end

      def relation_after_inclusion(subrelation)
        if includes.any?
          resource_class.include_via_call(subrelation, includes)
        else
          subrelation
        end
      end

      def relation_after_fields(subrelation)
        if fields.any?
          resource_class.sparse_fields_call(subrelation, fields)
        else
          subrelation
        end
      end

      def data
        payload.fetch("data", nil)
      end

      def type
        (@type || data["type"]).to_s.dasherize if @type || data
      end

      def attributes
        return unless data

        data
          .fetch("attributes", {})
          .transform_keys(&:underscore)
          .select(&resource_class.method(:valid_attribute?))
      end

      def relationships
        return unless data

        data
          .fetch("relationships", {})
          .transform_keys(&:underscore)
          .select(&resource_class.method(:valid_relationship?))
          .transform_values(&method(:as_relationship))
      end

      def as_relationship(value)
        if value.is_a?(Array)
          value.map do |member|
            data = member.fetch("data")
            mapping = JSONAPI::Realizer.type_mapping.fetch(data.fetch("type"))
            mapping.adapter.find_via_call(
              mapping.model_class,
              data.fetch("id")
            )
          end
        else
          data = value.fetch("data")
          mapping = JSONAPI::Realizer::Resource.type_mapping.fetch(data.fetch("type"))
          mapping.adapter.find_via_call(
            mapping.model_class,
            data.fetch("id")
          )
        end
      end

      def configuration
        JSONAPI::Realizer::Resource.type_mapping.fetch(type) if type
      end
    end
  end
end
