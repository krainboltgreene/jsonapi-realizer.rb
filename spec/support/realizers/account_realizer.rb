# frozen_string_literal: true

class AccountRealizer
  include(JSONAPI::Realizer::Resource)

  type(:people, class_name: "Account", adapter: :active_record)

  has_many(:comments, class_name: "CommentRealizer")
  has_many(:articles, class_name: "ArticleRealizer")

  has(:name)
end
