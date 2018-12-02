module JSONAPI
  module Realizer
    module Resource
      class Attribute
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:as)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:as)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end
      end
    end
  end
end
