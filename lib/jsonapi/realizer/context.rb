module JSONAPI
  module Realizer
    module Context
      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)
    end
  end
end
