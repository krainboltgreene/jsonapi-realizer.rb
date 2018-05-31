module JSONAPI
  module Realizer
    class Error
      class InvalidContentTypeHeader < Error
        def initialize(given:, wanted:)
          @given = given
          @wanted = wanted
        end
        
        def message
          "HTTP Content-Type Header recieved is #{@given}, but expected #{@wanted}"
        end
      end
    end
  end
end
