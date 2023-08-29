# frozen_string_literal: true

module JSONAPI
  module Realizer
    module Context
      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)
    end
  end
end
