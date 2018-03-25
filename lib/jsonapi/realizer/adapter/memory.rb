module JSONAPI
  module Realizer
    class Adapter
      MEMORY = Proc.new do
        find_many_via do |model_class|
          model_class.all
        end

        find_via do |model_class, id|
          model_class.fetch(id)
        end

        assign_attributes_via do |model, attributes|
          model.assign_attributes(attributes)
        end

        assign_relationships_via do |model, relationships|
          model.assign_attributes(relationships)
        end

        sparse_fields do |model_class, fields|
          model_class
        end

        include_via do |model_class, includes|
          model_class
        end
      end
    end
  end
end
