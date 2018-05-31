module JSONAPI
  module Realizer
    class Error
      class InvalidAcceptHeader < Error
        def initialize(given:, wanted:)
          @given = given
          @wanted = wanted
        end
        
        def message
          "HTTP Header recieved is #{given}, but expected #{wanted}"
        end
      end
    end
  end
end
