module JSONAPI
  module Realizer
    class Adapter
      ACTIVE_RECORD = Proc.new do
        find_many_via do |model_class|
          model_class.all
        end

        find_via do |model_class, id|
          model_class.find(id)
        end

        assign_attributes_via do |model, attributes|
          model.assign_attributes(attributes)
        end

        assign_relationships_via do |model, relationships|
          model.assign_attributes(relationships)
        end

        include_via do |model_class, includes|
          model_class.includes(includes.map(&(recursively_nest = -> (chains) do
            if chains.size == 1
              chains.first
            else
              {chains.first => recursively_nest.call(chains.drop(1))}
            end
          end)))
        end
      end
    end
  end
end
