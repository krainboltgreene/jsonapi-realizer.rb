# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Adapter
      include(ActiveModel::Model)

      require_relative("adapter/active_record")

      MAPPINGS = {
        active_record: JSONAPI::Realizer::Adapter::ActiveRecord
      }.freeze
      private_constant :MAPPINGS

      attr_accessor :interface

      validates_presence_of(:interface)

      def initialize(interface:)
        super(interface:)

        validate!

        mappings = MAPPINGS.merge(JSONAPI::Realizer.configuration.adapter_mappings).with_indifferent_access

        raise(ArgumentError, "you've given an invalid adapter alias: #{interface}, we support #{mappings.keys.to_sentence}") unless mappings.key?(interface)

        singleton_class.prepend(mappings.fetch(interface))

        raise(ArgumentError, "need to provide a Adapter#find_one interface") unless respond_to?(:find_one)
        raise(ArgumentError, "need to provide a Adapter#find_many interface") unless respond_to?(:find_many)
        raise(ArgumentError, "need to provide a Adapter#write_attributes interface") unless respond_to?(:write_attributes)
        raise(ArgumentError, "need to provide a Adapter#write_relationships interface") unless respond_to?(:write_relationships)
        raise(ArgumentError, "need to provide a Adapter#include_relationships interface") unless respond_to?(:include_relationships)
        raise(ArgumentError, "need to provide a Adapter#paginate interface") unless respond_to?(:paginate)
        raise(ArgumentError, "need to provide a Adapter#sorting interface") unless respond_to?(:sorting)
        raise(ArgumentError, "need to provide a Adapter#filtering interface") unless respond_to?(:filtering)
      end
    end
  end
end
