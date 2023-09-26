# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Error < StandardError
      include(ActiveModel::Model)

      require_relative("error/invalid_accept_type_header")
      require_relative("error/missing_accept_type_header")
      require_relative("error/invalid_content_type_header")
      require_relative("error/missing_content_type_header")
      require_relative("error/resource_attribute_not_found")
      require_relative("error/resource_relationship_not_found")
    end
  end
end
