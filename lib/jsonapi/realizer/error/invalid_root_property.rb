module JSONAPI
  module Realizer
    class Error
      class InvalidRootProperty < Error
        attr_accessor(:given)

        def message
          "root property was #{given}, which is not an Hash"
        end
      end
    end
  end
end
