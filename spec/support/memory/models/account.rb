class Account
  STORE = {}
  ATTRIBUTES = [:id, :name, :updated_at]

  include ActiveModel::Model
  include MemoryStore

  attr_accessor :id
  attr_accessor :name
  attr_accessor :updated_at
  attr_accessor :posts
end
