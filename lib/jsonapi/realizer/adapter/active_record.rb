module JSONAPI
  module Realizer
    module Adapter
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          find_via do |model_class, id|
            model_class.find(id)
          end

          write_attributes_via do |model, attributes|
            model.assign_attributes(attributes)
          end

          save_via do |model|
            model.save!
          end
        end
      end
    end
  end
end
