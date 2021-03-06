module JSONAPI
  module Realizer
    class Error < StandardError
      include(ActiveModel::Model)

      require_relative("error/invalid_content_type_header")
      require_relative("error/missing_content_type_header")
      require_relative("error/invalid_root_property")
      require_relative("error/missing_root_property")
      require_relative("error/missing_data_type_property")
      require_relative("error/include_without_data_property")
      require_relative("error/resource_attribute_not_found")
      require_relative("error/resource_relationship_not_found")
    end
  end
end
