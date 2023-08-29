# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Error
      class ResourceAttributeNotFound < Error
        attr_accessor(:name)
        attr_accessor(:realizer)

        def message
          "#{realizer} doesn't define the attribute #{name}"
        end
      end
    end
  end
end
