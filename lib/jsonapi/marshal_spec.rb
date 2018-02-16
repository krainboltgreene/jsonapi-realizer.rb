require "spec_helper"

module JSONAPI
  module Marshal
    module Resource
      extend ActiveSupport::Concern

      def valid_attribute?(name, value)
        configuration.fetch(:attributes, {}).fetch(name.to_sym)
      end

      def configuration
        self.class.configuration
      end

      class_methods do
        def represents(type, class_name:)
          @configuration = JSONAPI::Marshal.register(self, class_name.constantize, type.to_s)
        end

        def has_one(relationship)
          configuration[:relationships][name] = {name: relationship}
        end

        def attribute(name)
          configuration[:attributes][name] = {name: name}
        end

        def configuration
          @configuration
        end
      end
    end

    class Create
      def initialize(payload:, headers:)
        @data = payload.fetch("data")
        @type = @data.fetch("type")
        @resource = resource_class.new
      end

      def call
        @result ||= model_class.new.tap do |model|
          assign_attributes(model)
          associate_relationships(model)
        end
      end

      private def resource_class
        JSONAPI::Marshal.mapping.fetch(@type).fetch(:resource_class)
      end

      private def model_class
        JSONAPI::Marshal.mapping.fetch(@type).fetch(:model_class)
      end

      private def assign_attributes(model)
        model.assign_attributes(attributes)
      end

      private def associate_relationships(model)
        relationships.each do |name, value|
          binding.pry
          model.public_send()
        end
      end

      private def relationships
        @data.fetch("relationships", {}).select(&@resource.method(:valid_attribute?))
      end

      private def attributes
        @data.fetch("attributes", {}).select(&@resource.method(:valid_attribute?))
      end
    end

    def self.register(resource_class, model_class, type)
      @mapping ||= {}
      @mapping[type] = {
        model_class: model_class,
        type: type,
        resource_class: resource_class,
        attributes: {},
        relationships: {}
       }
    end

    def self.mapping
      @mapping
    end

    def self.create(payload, headers:)
      Create.new(payload: payload, headers: headers).call
    end
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
  attr_accessor :id
  attr_accessor :posts
end

class PhotoMarshal
  include JSONAPI::Marshal::Resource

  represents :photos, class_name: "Photo"

  has_one :photographer

  attribute :title
  attribute :src
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
