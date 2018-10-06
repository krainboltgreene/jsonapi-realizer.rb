require("pry")
require("rspec")
require("active_model")
require("active_record")
require("jsonapi-realizer")

require_relative "support/memory"
require_relative "support/example_action"

RSpec.configure do |let|
  # Enable flags like --only-failures and --next-failure
  let.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  let.disable_monkey_patching!

  # Exit the spec after the first failure
  # let.fail_fast = true

  # Only run a specific file, using the ENV variable
  # Example: FILE=lib/jsonapi/realizer/version_spec.rb bundle exec rake spec
  let.pattern = ENV["FILE"]

  # Show the slowest examples in the suite
  let.profile_examples = true

  # Colorize the output
  let.color = true

  # Output as a document string
  let.default_formatter = "doc"

  let.before(:each, memory: true) do
    Account::STORE.clear
    Photo::STORE.clear
    Post::STORE.clear
    Comment::STORE.clear
  end

  let.after(:each, memory: true) do
    Account::STORE.clear
    Photo::STORE.clear
    Post::STORE.clear
    Comment::STORE.clear
  end

  let.before(:each, active_record: true) do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
  end

  let.before(:each, active_record: true) do
    ActiveRecord::Migration.create_table(:items, force: true) do |table|
      table.integer :subtotal_cents, default: 0, null: false
      table.integer :discount_cents, default: 0, null: false
      table.integer :cart_id, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end

  let.before(:each, active_record: true) do
    ActiveRecord::Migration.create_table(:carts, force: true) do |table|
      table.integer :discount_cents, default: 0, null: false
      table.string :state, null: false
      table.string :status, null: false, default: :started
      table.integer :consumer_id, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end

  let.before(:each, active_record: true) do
    ActiveRecord::Migration.create_table(:consumers, force: true) do |table|
      table.string :email, default: 0, null: false
      table.integer :credit_cents, default: 0, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end

  let.around(:each, active_record: true) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
