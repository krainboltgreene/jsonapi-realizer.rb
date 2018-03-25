module JSONAPI
  module Realizer
    class Error < StandardError
      require_relative "error/include_without_data_property"
      require_relative "error/invalid_accept_header"
      require_relative "error/invalid_content_type_header"
      require_relative "error/malformed_data_root_property"
      require_relative "error/missing_accept_header"
      require_relative "error/missing_content_type_header"
      require_relative "error/missing_root_property"
      require_relative "error/missing_type_resource_property"
    end
  end
end
