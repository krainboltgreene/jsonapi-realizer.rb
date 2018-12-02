class ArticleRealizer
  include(JSONAPI::Realizer::Resource)

  type(:articles, :class_name => "Article", :adapter => :active_record)

  has_one(:author, :as => :account, :class_name => "AccountRealizer")
  has_many(:comments, :class_name => "CommentRealizer")

  has(:title)
end
