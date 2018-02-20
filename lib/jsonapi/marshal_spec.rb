require "spec_helper"

module InMemoryStore
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
  end
end

class Photo
  STORE = {}
  ATTRIBUTES = [:id, :title, :src, :updated_at]

  include ActiveModel::Model
  include InMemoryStore

  attr_accessor :id
  attr_accessor :title
  attr_accessor :src
  attr_accessor :photographer
  attr_accessor :updated_at
end

class People
  STORE = {}
  ATTRIBUTES = [:id, :name, :updated_at]

  include ActiveModel::Model
  include InMemoryStore

  attr_accessor :id
  attr_accessor :name
  attr_accessor :posts
  attr_accessor :updated_at
end

class PhotoMarshal < JSONAPI::Marshal::Resource
  represents :photos, class_name: "Photo"

  find_via do |model_class, id|
    model_class.fetch(id)
  end

  has_one :photographer, as: :people

  has :title
  has :src
end

class PeopleMarshal < JSONAPI::Marshal::Resource
  represents :people, class_name: "People"

  find_via do |model_class, id|
    model_class.fetch(id)
  end

  has :name
end

RSpec.describe JSONAPI::Marshal do
  it "on create generates a model with a relationship and a client id" do
    People::STORE["4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9"] = {
      id: "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9",
      name: "Kurtis Rainbolt-Greene"
    }
    headers = {
      "Content-Type" => "application/vnd.api+json",
      "Accept" => "application/vnd.api+json"
    }
    params = {
      "data" => {
        "id" => "550e8400-e29b-41d4-a716-446655440000",
        "type" => "photos",
        "attributes" => {
          "title" => "Ember Hamster",
          "src" => "http://example.com/images/productivity.png"
        },
        "relationships" => {
          "photographer" => {
            "data" => { "type" => "people", "id" => "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9" }
          }
        }
      }
    }
    model = JSONAPI::Marshal.create(params, headers: headers)

    expect(model).to be_a_kind_of(Photo)
    expect(model).to have_attributes(title: "Ember Hamster", src: "http://example.com/images/productivity.png", updated_at: a_kind_of(Time))
    expect(model).to have_attributes(photographer: a_kind_of(People))
    expect(model.photographer).to have_attributes(id: "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9")
    expect(model.class.const_get("STORE")).to include("550e8400-e29b-41d4-a716-446655440000" => hash_including(id: "550e8400-e29b-41d4-a716-446655440000", title: "Ember Hamster", src: "http://example.com/images/productivity.png"))
  end
end
