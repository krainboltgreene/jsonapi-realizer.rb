module JSONAPI
  module Realizer
    class Error
      class MalformedDataRootProperty < Error
        def initialize(given:)
          @given = given
        end
        
        def message
          "data property was #{@given}, which is not an Array, Hash, or nil"
        end
      end
    end
  end
end
