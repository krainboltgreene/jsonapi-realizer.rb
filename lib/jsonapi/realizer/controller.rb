module JSONAPI
  module Realizer
    module Controller
      private def reject_missing_content_type_header
        return if request.body.size.zero?
        return if request.headers.property?("Content-Type")

        raise(JSONAPI::Realizer.configuration.default_missing_content_type_exception)
      end

      private def reject_invalid_content_type_header
        reject_missing_content_type_header

        return if request.headers.fetch("Content-Type").include?(JSONAPI::MEDIA_TYPE)

        raise(JSONAPI::Realizer.configuration.default_invalid_content_type_exception)
      end

      private def reject_missing_root_property
        return if request.parameters.key?("body")
        return if request.paremters.key?("errors")
        return if request.paremters.key?("meta")

        raise(Error::MissingRootProperty)
      end

      private def reject_invalid_root_property
        reject_missing_root_property

        return unless request.parameters.key?("data") && (request.parameters.fetch("data").is_a?(Hash) || request.parameters.fetch("data").is_a?(Array))
        return unless request.parameters.key?("errors") && request.parameters.fetch("errors").is_a?(Array)

        raise(Error::InvalidRootProperty)
      end

      private def reject_missing_type_property
        reject_invalid_root_property

        return if request.parameters.fetch("data").is_a?(Hash) && request.parameters.fetch("data").key?("type")
        return if request.parameters.fetch("data").is_a?(Array) && request.parameters.fetch("data").all? { |data| data.key?("type") }

        raise(Error::MissingDataTypeProperty)
      end

      private def reject_invalid_type_property
        reject_missing_type_property

        return if request.parameters.fetch("data").is_a?(Hash) && request.parameters.fetch("data").fetch("type").is_a?(String) && request.parameters.fetch("data").fetch("type").present?
        return if request.parameters.fetch("data").is_a?(Array) && request.parameters.fetch("data").map {|data| data.fetch("type")}.all? {|type| type.is_a?(String) && type.present? }

        raise(Error::InvalidDataTypeProperty)
      end
    end
  end
end
