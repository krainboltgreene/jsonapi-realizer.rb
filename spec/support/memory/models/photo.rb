class Photo
  STORE = {}
  ATTRIBUTES = [:id, :title, :alt_text, :src, :updated_at]

  include ActiveModel::Model
  include MemoryStore

  attr_accessor :id
  attr_accessor :title
  attr_accessor :alt_text
  attr_accessor :src
  attr_accessor :updated_at
  attr_accessor :active_photographer
end
