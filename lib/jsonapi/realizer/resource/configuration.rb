# frozen_string_literal: true

module JSONAPI
  module Realizer
    module Resource
      class Configuration
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:type)
        attr_accessor(:model_class)
        attr_accessor(:adapter)
        attr_accessor(:attributes)
        attr_accessor(:relations)

        validates_presence_of(:owner)
        validates_presence_of(:type)
        validates_presence_of(:adapter)
        validates_presence_of(:model_class)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end
      end
    end
  end
end
