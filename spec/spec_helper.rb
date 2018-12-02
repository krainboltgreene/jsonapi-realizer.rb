require("pry")
require("rspec")
require("active_model")
require("active_record")
require("jsonapi-realizer")

JSONAPI::Realizer.configuration do |let|
  let.default_identifier = :id
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require_relative("support/models/application_record")
require_relative("support/models/article")
require_relative("support/models/account")
require_relative("support/models/comment")
require_relative("support/models/photo")
require_relative("support/realizers/article_realizer")
require_relative("support/realizers/account_realizer")
require_relative("support/realizers/comment_realizer")
require_relative("support/realizers/photo_realizer")

RSpec.configure do |let|
  # Enable flags like --only-failures and --next-failure
  let.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  let.disable_monkey_patching!

  # Exit the spec after the first failure
  # let.fail_fast = true

  # Only run a specific file, using the ENV variable
  # Example => FILE=lib/jsonapi/realizer/version_spec.rb bundle exec rake spec
  let.pattern = ENV["FILE"]

  # Show the slowest examples in the suite
  let.profile_examples = true

  # Colorize the output
  let.color = true

  # Output as a document string
  let.default_formatter = "doc"

  let.before(:each) do
    ApplicationRecord.descendants.each(&:setup!)
  end

  let.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
