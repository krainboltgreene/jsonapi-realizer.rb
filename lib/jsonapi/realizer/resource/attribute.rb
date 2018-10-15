module JSONAPI
  module Realizer
    module Resource
      class Attribute
        include(ActiveModel::Model)

        attr_accessor(:name)
        attr_accessor(:as)
        attr_accessor(:visible)
        attr_accessor(:owner)

        validates_presence_of(:name)
        validates_presence_of(:as)
        validates_inclusion_of(:visible, :in => [true, false])
        validates_presence_of(:owner)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end
      end
    end
  end
end
