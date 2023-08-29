# frozen_string_literal: true

class PhotoRealizer
  include(JSONAPI::Realizer::Resource)

  type(:photos, class_name: "Photo", adapter: :active_record)

  has_one(:photographer, class_name: "AccountRealizer")

  has(:title)
  has(:src)
end
