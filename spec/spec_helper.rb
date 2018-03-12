require "pry"
require "rspec"
require "jsonapi-realizer"
require "active_model"

module MemoryStore
  extend ActiveSupport::Concern

  def create
    assign_attributes(updated_at: Time.now, id: id || SecureRandom.uuid)
    self.class.const_get("STORE")[id] = self.class.const_get("ATTRIBUTES").inject({}) do |hash, key|
      hash.merge({ key => self.send(key) })
    end
  end

  class_methods do
    def fetch(id)
      self.new(self.const_get("STORE").fetch(id))
    end

    def all
      self.const_get("STORE").values.map(&method(:new))
    end
  end
end

class Photo
  STORE = {}
  ATTRIBUTES = [:id, :title, :alt_text, :src, :updated_at]

  include ActiveModel::Model
  include MemoryStore

  attr_accessor :id
  attr_accessor :title
  attr_accessor :alt_text
  attr_accessor :src
  attr_accessor :active_photographer
  attr_accessor :updated_at
end

class People
  STORE = {}
  ATTRIBUTES = [:id, :name, :updated_at]

  include ActiveModel::Model
  include MemoryStore

  attr_accessor :id
  attr_accessor :name
  attr_accessor :posts
  attr_accessor :updated_at
end

class PhotoRealizer < JSONAPI::Realizer::Resource
  register :photos, class_name: "Photo", adapter: :memory

  has_one :active_photographer, as: :people

  has :title
  has :alt_text
  has :src
end

class PeopleRealizer < JSONAPI::Realizer::Resource
  register :photographer_people, class_name: "People", adapter: :memory

  has_many :photos

  has :name
end

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

  let.before(:each) do
    People::STORE.clear
    Photo::STORE.clear
  end

  let.after(:each) do
    People::STORE.clear
    Photo::STORE.clear
  end
end
