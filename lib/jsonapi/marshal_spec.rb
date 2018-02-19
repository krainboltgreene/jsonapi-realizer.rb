require "spec_helper"

module InMemoryStore
  def find_by_identifier(mapping, id)
    binding.pry
  end
end

class Photo
  include ActiveModel::Model

  attr_accessor :id
  attr_accessor :title
  attr_accessor :src
  attr_accessor :photographer
end

class People
  include ActiveModel::Model

  attr_accessor :id
  attr_accessor :name
  attr_accessor :posts
end

class PhotoMarshal < JSONAPI::Marshal::Resource
  adapter InMemoryStore

  represents :photos, class_name: "Photo"

  has_one :photographer, as: :people

  has :title
  has :src
end

class PeopleMarshal < JSONAPI::Marshal::Resource
  represents :people, class_name: "People"

  has :name
end

RSpec.describe JSONAPI::Marshal do
  it "on create generates a model with a relationship and a client id" do
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
            "data" => { "type" => "people", "id" => "9" }
          }
        }
      }
    }
    model = JSONAPI::Marshal.create(params, headers: headers)

    expect(model).to be_a_kind_of(Photo)
    expect(model).to have_attributes(title: "Ember Hamster", src: "http://example.com/images/productivity.png")
    expect(model).to have_attributes(photographer: a_kind_of(People))
    export(model.photographer).to have_attributes(id: "9")
  end
end
