# frozen_string_literal: true

module JSONAPI
  module Realizer
    class Error
      class InvalidAcceptTypeHeader < Error
        attr_accessor(:key)
        attr_accessor(:given)
        attr_accessor(:wanted)

        def message
          "HTTP #{key} Header recieved is #{given}, but expected #{wanted}"
        end
      end
    end
  end
end
