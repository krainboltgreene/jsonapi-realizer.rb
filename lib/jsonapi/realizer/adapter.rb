module JSONAPI
  module Realizer
    class Adapter
      require_relative "adapter/active_record"
      require_relative "adapter/memory"

      MAPPINGS = {
        memory: JSONAPI::Realizer::Adapter::MEMORY,
        active_record: JSONAPI::Realizer::Adapter::ACTIVE_RECORD,
      }

      def initialize(interface)
        if JSONAPI::Realizer::Adapter::MAPPINGS.key?(interface.to_sym)
          instance_eval(&JSONAPI::Realizer::Adapter::MAPPINGS.fetch(interface.to_sym))
        else
          raise ArgumentError, "you've given an invalid adapter alias: #{interface}, we support #{JSONAPI::Realizer::Adapter::MAPPINGS.keys}"
        end

        raise ArgumentError, "need to provide a Adapter.find_via interface" unless instance_variable_defined?(:@find_via_call)
        raise ArgumentError, "need to provide a Adapter.find_many_via_call interface" unless instance_variable_defined?(:@find_many_via_call)
        raise ArgumentError, "need to provide a Adapter.assign_attributes_via interface" unless instance_variable_defined?(:@assign_attributes_via_call)
        raise ArgumentError, "need to provide a Adapter.assign_relationships_via interface" unless instance_variable_defined?(:@assign_relationships_via_call)
        raise ArgumentError, "need to provide a Adapter.sparse_fields interface" unless instance_variable_defined?(:@sparse_fields_call)
        raise ArgumentError, "need to provide a Adapter.include_via interface" unless instance_variable_defined?(:@include_via_call)
      end

      def find_via(&callback)
        @find_via_call = callback
      end

      def find_many_via(&callback)
        @find_many_via_call = callback
      end

      def assign_attributes_via(&callback)
        @assign_attributes_via_call = callback
      end

      def assign_relationships_via(&callback)
        @assign_relationships_via_call = callback
      end

      def sparse_fields(&callback)
        @sparse_fields_call = callback
      end

      def include_via(&callback)
        @include_via_call = callback
      end

      def find_via_call(model_class, id)
        @find_via_call.call(model_class, id)
      end

      def find_many_via_call(model_class)
        @find_many_via_call.call(model_class)
      end

      def assign_attributes_via_call(model, attributes)
        @assign_attributes_via_call.call(model, attributes)
      end

      def assign_relationships_via_call(model, relationships)
        @assign_relationships_via_call.call(model, relationships)
      end

      def sparse_fields_call(model_class, fields)
        @sparse_fields_call.call(model_class, fields)
      end

      def include_via_call(model_class, includes)
        @include_via_call.call(model_class, includes)
      end
    end
  end
end
