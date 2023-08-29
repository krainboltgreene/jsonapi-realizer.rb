# frozen_string_literal: true

require("spec_helper")

RSpec.describe(JSONAPI::Realizer::Resource) do
  let(:resource_class) { PhotoRealizer }
  let(:resource) { resource_class.new(intent:, parameters:, headers:) }

  describe "#as_native" do
    subject { resource }

    context "when accepting the right type, when creating with data, with spares fields, and includes" do
      let(:intent) { :create }
      let(:parameters) do
        {
          "include" => "photographer",
          "fields" => {
            "articles" => "title,body,sub-text",
            "people" => "name"
          },
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
      end
      let(:headers) do
        {
          "Accept" => "application/vnd.api+json",
          "Content-Type" => "application/vnd.api+json"
        }
      end

      before do
        Account.create!(id: 9, name: "Dan Gebhardt", twitter: "dgeb")
      end

      it "object is a Photo" do
        expect(subject.object).to be_a(Photo)
      end

      it "object isn't saved" do
        expect(subject.object).not_to be_persisted
      end

      it "object has the right attributes" do
        expect(subject.object).to have_attributes(
          title: "Ember Hamster",
          src: "http://example.com/images/productivity.png"
        )
      end

      it "has a photographer" do
        expect(subject.object.photographer).not_to be_nil
      end
    end

    context "when specifying nil relationship" do
      let(:intent) { :update }
      let(:parameters) do
        {
          "id" => "11",
          "data" => {
            "id" => "11",
            "type" => "photos",
            "relationships" => {
              "photographer" => nil
            }
          }
        }
      end
      let(:headers) do
        {
          "Accept" => "application/vnd.api+json",
          "Content-Type" => "application/vnd.api+json"
        }
      end

      before do
        account = Account.create!(id: 9, name: "Dan Gebhardt", twitter: "dgeb")
        Photo.create!(id: 11, photographer: account, title: "Ember Hamster", src: "http://example.com/images/productivity.png")
      end

      it "object is a Photo" do
        expect(subject.object).to be_a(Photo)
      end

      it "clears relationship on realizing nil" do
        expect(subject.object.photographer).to be_nil
      end
    end
  end
end
