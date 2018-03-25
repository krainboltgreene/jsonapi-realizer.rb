require "spec_helper"

RSpec.describe JSONAPI::Realizer::Action::Create do
  let(:action) { described_class.new(payload: payload, headers: headers) }

  describe "#call" do
    subject { action.call }

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

      shared_examples "api" do
        it "is the right model" do
          subject

          expect(action.model).to be_a_kind_of(Photo)
        end

        it "assigns the title attribute" do
          subject

          expect(action.model).to have_attributes(title: "Ember Hamster")
        end

        it "assigns the alt_text attribute" do
          subject

          expect(action.model).to have_attributes(alt_text: "A hamster logo.")
        end

        it "assigns the src attribute" do
          subject

          expect(action.model).to have_attributes(src: "http://example.com/images/productivity.png")
        end

        it "assigns the active_photographer attribute" do
          subject

          expect(action.model).to have_attributes(active_photographer: a_kind_of(Account))
        end
      end

      context "in a memory store", memory: true do
        before do
          Account::STORE["4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9"] = {
            id: "4b8a0af6-953d-4729-8b9a-1fa4eb18f3c9",
            name: "Kurtis Rainbolt-Greene"
          }
        end

        include_examples "api"

        it "creates the new record" do
          expect(subject.model).to have_attributes(
            title: "Ember Hamster",
            alt_text: "A hamster logo.",
            src: "http://example.com/images/productivity.png"
          )
        end
      end
    end
  end
end
