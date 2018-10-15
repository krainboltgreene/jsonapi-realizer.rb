module JSONAPI
  module Realizer
    class Adapter
      module ActiveRecord
        def find_many(scope, conditions = {})
          scope.where(conditions)
        end

        def find_one(scope, id)
          scope.find(id)
        end

        def paginate(scope, per, offset)
          scope.page(offset).per(per)
        end

        def write_attributes(model, attributes)
          model.assign_attributes(attributes)
        end

        def write_relationships(model, relationships)
          model.assign_attributes(relationships)
        end

        def include_relationships(scope, includes)
          scope.includes(*includes.map(&method(:arel_chain)))
        end

        private def arel_chain(chains)
          if chains.size == 1
            chains.first
          else
            {chains.first => arel_chain(chains.drop(1))}
          end
        end
      end
    end
  end
end
