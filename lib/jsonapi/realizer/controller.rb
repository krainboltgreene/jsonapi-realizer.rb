# frozen_string_literal: true

module JSONAPI
  module Realizer
    module Controller
      private def reject_missing_accept_type_header
        return if request.body.read.empty?
        return if request.headers.key?("HTTP_ACCEPT")

        raise(JSONAPI::Realizer.configuration.default_missing_accept_type_exception)
      end

      private def reject_invalid_accept_type_header
        reject_missing_accept_type_header

        return if request.headers.fetch("HTTP_ACCEPT").include?(JSONAPI::MEDIA_TYPE)

        raise(JSONAPI::Realizer.configuration.default_invalid_accept_type_exception, given: request.headers.fetch("HTTP_ACCEPT"), wanted: JSONAPI::MEDIA_TYPE, key: "Accept")
      end

      private def reject_missing_content_type_header
        return if request.body.read.empty?
        return if request.headers.key?("Content-Type")

        raise(JSONAPI::Realizer.configuration.default_missing_content_type_exception)
      end

      private def reject_invalid_content_type_header
        reject_missing_content_type_header

        return if request.headers.fetch("Content-Type").include?(JSONAPI::MEDIA_TYPE)

        raise(JSONAPI::Realizer.configuration.default_invalid_content_type_exception, given: request.headers.fetch("Content-Type"), wanted: JSONAPI::MEDIA_TYPE, key: "Content-Type")
      end
    end
  end
end
