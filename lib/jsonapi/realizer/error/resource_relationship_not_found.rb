# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Error
      class ResourceRelationshipNotFound < Error
        attr_accessor(:name)
        attr_accessor(:realizer)
        attr_accessor(:key)

        def message
          if key
            "#{realizer} doesn't define the relationship #{name} with #{key}"
          else
            "#{realizer} doesn't define the relationship #{name}"
          end
        end
      end
    end
  end
end
