class Account < ApplicationRecord
  has_many(:articles)
  has_many(:comments)

  def self.setup!
    ActiveRecord::Migration.create_table(:accounts, :force => true) do |table|
      table.text(:name, :null => false)
      table.text(:twitter, :null => false)
      table.timestamps(:null => false)
    end
  end
end
