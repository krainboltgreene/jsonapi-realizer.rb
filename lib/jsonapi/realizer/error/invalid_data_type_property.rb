# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Error
      class InvalidDataTypeProperty < Error
        attr_accessor(:given)

        def message
          "root.data property was #{given}, which is not an Hash, Array, or nil"
        end
      end
    end
  end
end
