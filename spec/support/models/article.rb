class Article < ApplicationRecord
  belongs_to(:account)
  has_many(:comments)

  def self.setup!
    ActiveRecord::Migration.create_table(:articles, :force => true) do |table|
      table.text(:title, :null => false)
      table.references(:account)
      table.timestamps(:null => false)
    end
  end
end
