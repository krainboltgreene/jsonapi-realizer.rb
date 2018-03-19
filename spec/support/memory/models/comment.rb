class Comment
  STORE = {}
  ATTRIBUTES = [:id, :body, :updated_at]

  include ActiveModel::Model
  include MemoryStore

  attr_accessor :id
  attr_accessor :body
  attr_accessor :updated_at
  attr_accessor :post
end
