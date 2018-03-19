class PhotoRealizer
  include JSONAPI::Realizer::Resource

  register :photos, class_name: "Photo", adapter: :memory

  has_one :active_photographer, as: :photographer_accounts

  has :title
  has :alt_text
  has :src
end
