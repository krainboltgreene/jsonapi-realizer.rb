class CommentRealizer
  include(JSONAPI::Realizer::Resource)

  type(:comments, :class_name => "Comment", :adapter => :active_record)

  has_one(:author, :as => :account, :class_name => "AccountRealizer")
  has_one(:article, :class_name => "ArticleRealizer")

  has(:title)
end
