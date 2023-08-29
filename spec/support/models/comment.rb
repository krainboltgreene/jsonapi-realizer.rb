# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to(:article)
  belongs_to(:account)

  def self.setup!
    ActiveRecord::Migration.create_table(:comments, force: true) do |table|
      table.text(:body, null: false)
      table.references(:account)
      table.references(:article)
      table.timestamps(null: false)
    end
  end
end
