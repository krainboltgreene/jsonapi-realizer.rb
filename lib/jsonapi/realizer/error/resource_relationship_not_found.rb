module JSONAPI
  module Realizer
    class Error
      class ResourceRelationshipNotFound < Error
        attr_accessor(:name)
        attr_accessor(:realizer)

        def message
          "#{realizer} doesn't define the relationship #{name}"
        end
      end
    end
  end
end
