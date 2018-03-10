module JSONAPI
  module Realizer
    module Adapter
      require_relative "adapter/active_record"
      require_relative "adapter/memory"

      MAPPINGS = {
        memory: JSONAPI::Realizer::Adapter::Memory,
        active_record: JSONAPI::Realizer::Adapter::ActiveRecord,
      }

      def self.adapt(resource, interface, &block)
        if interface.kind_of?(Symbol)
          if JSONAPI::Realizer::Adapter::MAPPINGS.key?(interface)
            resource.include(JSONAPI::Realizer::Adapter::MAPPINGS.fetch(interface))
          else
            raise ArgumentError, "you've given an invalid adapter alias: #{interface}, we support #{JSONAPI::Realizer::Adapter::MAPPINGS.keys}"
          end
        else
          resource.include(interface)
        end

        if block_given?
          resource.instance_eval(&block)
        end

        raise ArgumentError, "need to provide a Adapter.find_via interface" unless resource.instance_variable_defined?(:@find_via_call)
        raise ArgumentError, "need to provide a Adapter.find_many_via_call interface" unless resource.instance_variable_defined?(:@find_many_via_call)
        raise ArgumentError, "need to provide a Adapter.assign_attributes_via interface" unless resource.instance_variable_defined?(:@assign_attributes_via_call)
        raise ArgumentError, "need to provide a Adapter.create_via interface" unless resource.instance_variable_defined?(:@create_via_call)
        raise ArgumentError, "need to provide a Adapter.update_via interface" unless resource.instance_variable_defined?(:@update_via_call)
        raise ArgumentError, "need to provide a Adapter.sparse_fields interface" unless resource.instance_variable_defined?(:@sparse_fields_call)
        raise ArgumentError, "need to provide a Adapter.include_via interface" unless resource.instance_variable_defined?(:@include_via_call)
      end
    end
  end
end
