module JSONAPI
  module Realizer
    class Adapter
      module ActiveRecord
        def find_many(scope)
          scope.all
        end

        def find_one(scope, id)
          scope.find(id)
        end

        def filtering(scope, filters)
          scope.where(filters.slice(*scope.column_names))
        end

        def sorting(scope, sorts)
          scope.order(
            *sorts.
              map do |(keychain, direction)|
                [keychain, if direction == "-" then :DESC else :ASC end]
              end.
              map do |(keychain, direction)|
                [keychain.map {|key| key.inspect}.join("."), direction]
              end.
              map do |pair|
                Arel.sql(pair.join(" "))
              end
          )
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
          scope.eager_load(*includes.map(&method(:arel_chain)))
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
