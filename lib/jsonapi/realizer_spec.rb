require "spec_helper"

RSpec.describe JSONAPI::Realizer do
  describe ".index" do
    subject { JSONAPI::Realizer.index(payload, headers: headers, type: type) }

    context "with no top-level data and good headers"
    context "with no top-level data and bad headers"
    context "with a good payload and bad headers"

    context "with a good payload and good headers" do
      let(:payload) do
        {}
      end
      let(:headers) do
        {
          "Content-Type" => "application/vnd.api+json",
          "Accept" => "application/vnd.api+json"
        }
      end
      let(:type) do
        :photos
      end

      before do
        Photo::STORE["550e8400-e29b-41d4-a716-446655440000"] = {
          id: "550e8400-e29b-41d4-a716-446655440000",
          title: "Ember Hamster",
          src: "http://example.com/images/productivity.png"
        }
        Photo::STORE["d09ae4c6-0fc3-4c42-8fe8-6029530c3bed"] = {
          id: "d09ae4c6-0fc3-4c42-8fe8-6029530c3bed",
          title: "Ember Fox",
          src: "http://example.com/images/productivity-2.png"
        }
      end

      it "returns an action that has N models" do
        expect(subject).to have_attributes(models: [a_kind_of(Photo), a_kind_of(Photo)])
      end
    end
  end

  describe ".show" do
    subject { JSONAPI::Realizer.show(payload, headers: headers, type: type) }

    context "with no top-level data and good headers"
    context "with no top-level data and bad headers"
    context "with a good payload and bad headers"

    context "with a good payload and good headers" do
      let(:payload) do
        {
          "id" => "d09ae4c6-0fc3-4c42-8fe8-6029530c3bed"
        }
      end
      let(:headers) do
        {
          "Content-Type" => "application/vnd.api+json",
          "Accept" => "application/vnd.api+json"
        }
      end
      let(:type) do
        :photos
      end

      before do
        Photo::STORE["d09ae4c6-0fc3-4c42-8fe8-6029530c3bed"] = {
          id: "d09ae4c6-0fc3-4c42-8fe8-6029530c3bed",
          title: "Ember Fox",
          src: "http://example.com/images/productivity-2.png"
        }
      end

      it "returns an action that a model" do
        expect(subject).to have_attributes(model: a_kind_of(Photo))
      end
    end
  end

  describe ".create" do
    subject { JSONAPI::Realizer.create(payload, headers: headers) }

    context "with no top-level data and good headers"
    context "with no top-level data and bad headers"
    context "with a good payload and bad headers"

    context "with a good payload and good headers" do
      let(:payload) do
        {
          "data" => {
            "id" => "550e8400-e29b-41d4-a716-446655440000",
            "type" => "photos",
            "attributes" => {
              "title" => "Ember Hamster",
              "alt-text" => "A hamster logo.",
              "src" => "http://example.com/images/productivity.png"
            },
            "relationships" => {
              "active-photographer" => {
                "data" => { "type" => "photographer-accounts", "id" => "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9" }
              }
            }
          }
        }
      end
      let(:headers) do
        {
          "Content-Type" => "application/vnd.api+json",
          "Accept" => "application/vnd.api+json"
        }
      end

      before do
        Account::STORE["4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9"] = {
          id: "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9",
          name: "Kurtis Rainbolt-Greene"
        }
      end

      it "returns an action that a model" do
        expect(subject).to have_attributes(model: a_kind_of(Photo))
      end
    end
  end
end
