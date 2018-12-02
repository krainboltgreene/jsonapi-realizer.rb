require("ostruct")
require("addressable")
require("active_model")
require("active_support/concern")
require("active_support/core_ext/enumerable")
require("active_support/core_ext/string")
require("active_support/core_ext/module")

module JSONAPI
  MEDIA_TYPE = "application/vnd.api+json" unless const_defined?("MEDIA_TYPE")

  module Realizer
    require_relative("realizer/version")
    require_relative("realizer/error")
    require_relative("realizer/configuration")
    require_relative("realizer/controller")

    @configuration ||= Configuration.new(
      :default_invalid_content_type_exception => JSONAPI::Realizer::Error::InvalidContentTypeHeader,
      :default_missing_content_type_exception => JSONAPI::Realizer::Error::MissingContentTypeHeader,
      :default_identifier => :id,
      :adapter_mappings => {}
    )

    require_relative("realizer/adapter")
    require_relative("realizer/context")
    require_relative("realizer/resource")

    def self.configuration
      if block_given?
        yield(@configuration)
      else
        @configuration
      end
    end
  end
end
