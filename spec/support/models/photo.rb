class Photo < ApplicationRecord
  belongs_to(:photographer, :class_name => "Account")

  def self.setup!
    ActiveRecord::Migration.create_table(:photos, :force => true) do |table|
      table.text(:title, :null => false)
      table.text(:src, :null => false)
      table.references(:photographer)
      table.timestamps(:null => false)
    end
  end
end
