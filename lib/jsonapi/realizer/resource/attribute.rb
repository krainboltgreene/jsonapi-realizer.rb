module JSONAPI
  module Realizer
    module Resource
      class Attribute
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:as)
        attr_accessor(:visible)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:as)
        validates_inclusion_of(:visible, :in => [true, false])

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end
      end
    end
  end
end
