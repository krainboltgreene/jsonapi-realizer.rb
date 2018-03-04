module JSONAPI
  module Realizer
    module Adapter
      module Memory
        extend ActiveSupport::Concern

        included do
          find_via do |model_class, id|
            model_class.fetch(id)
          end

          write_attributes_via do |model, attributes|
            model.assign_attributes(attributes)
          end

          save_via do |model|
            model.assign_attributes(id: model.id || SecureRandom.uuid)
            model.assign_attributes(updated_at: Time.now)
            model_class.const_get("STORE")[model.id] = model_class.const_get("ATTRIBUTES").inject({}) do |hash, key|
              hash.merge({ key => model.public_send(key) })
            end
          end
        end
      end
    end
  end
end
