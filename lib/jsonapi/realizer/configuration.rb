# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Configuration
      include(ActiveModel::Model)

      attr_accessor(:default_origin)
      attr_accessor(:default_identifier)
      attr_accessor(:adapter_mappings)
      attr_accessor(:default_missing_accept_type_exception)
      attr_accessor(:default_invalid_accept_type_exception)
      attr_accessor(:default_missing_content_type_exception)
      attr_accessor(:default_invalid_content_type_exception)

      validates_presence_of(:default_missing_accept_type_exception)
      validates_presence_of(:default_invalid_accept_type_exception)
      validates_presence_of(:default_missing_content_type_exception)
      validates_presence_of(:default_invalid_content_type_exception)

      def initialize(**keyword_arguments)
        super(**keyword_arguments)

        validate!
      end
    end
  end
end
