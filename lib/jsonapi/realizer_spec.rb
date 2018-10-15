require "spec_helper"

RSpec.describe JSONAPI::Realizer do
  let(:parameters) {
    {
      "data" => {
        "type" => "photos",
        "attributes" => {
          "title" => "Ember Hamster",
          "src" => "http://example.com/images/productivity.png"
        },
        "relationships" => {
          "photographer" => {
            "data" => {
              "type" => "people",
              "id" => "9"
            }
          }
        }
      }
    }
  }
  let(:headers) {
    {
      "Accept" => "application/vnd.api+json",
      "Content-Type" => "application/vnd.api+json"
    }
  }
end
