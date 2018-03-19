class AccountRealizer
  include JSONAPI::Realizer::Resource

  register :photographer_accounts, class_name: "Account", adapter: :memory

  has_many :photos
  has_many :posts

  has :name
end
