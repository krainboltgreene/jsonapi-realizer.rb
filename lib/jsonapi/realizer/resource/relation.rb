module JSONAPI
  module Realizer
    module Resource
      class Relation
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:type)
        attr_accessor(:as)
        attr_accessor(:realizer_class_name)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:type)
        validates_presence_of(:as)
        validates_presence_of(:realizer_class_name)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        def realizer_class
          realizer_class_name.constantize
        end
      end
    end
  end
end
