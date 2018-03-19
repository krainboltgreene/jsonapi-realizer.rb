class Post
  STORE = {}
  ATTRIBUTES = [:id, :title, :updated_at]

  include ActiveModel::Model
  include MemoryStore

  attr_accessor :id
  attr_accessor :title
  attr_accessor :updated_at
  attr_accessor :author
end
