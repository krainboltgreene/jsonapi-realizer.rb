class CommentRealizer
  include JSONAPI::Realizer::Resource

  register :comments, class_name: "Comment", adapter: :memory

  has_one :post

  has :title
end
