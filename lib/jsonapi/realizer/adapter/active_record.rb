module JSONAPI
  module Realizer
    module Adapter
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          find_many_via do |model_class|
            model_class.all
          end

          find_via do |model_class, id|
            model_class.find(id)
          end

          write_attributes_via do |model, attributes|
            model.assign_attributes(attributes)
          end

          fields_via do |model_class, fields|
            model_class.select(fields)
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

          save_via do |model|
            model.save!
          end
        end
      end
    end
  end
end
