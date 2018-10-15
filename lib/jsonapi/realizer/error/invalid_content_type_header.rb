module JSONAPI
  module Realizer
    class Error
      class InvalidContentTypeHeader < Error
        attr_accessor(:given)
        attr_accessor(:wanted)

        def message
          "HTTP Content-Type Header recieved is #{given}, but expected #{wanted}"
        end
      end
    end
  end
end
