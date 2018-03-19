class PostRealizer
  include JSONAPI::Realizer::Resource

  register :posts, class_name: "Post", adapter: :memory

  has_one :author, as: :photographer_accounts
  has_many :comments, includable: false

  has :title
end
