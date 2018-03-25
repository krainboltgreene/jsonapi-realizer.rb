require "spec_helper"

RSpec.describe JSONAPI::Realizer::Action do
  let(:headers) do
    {
      "Accept" => JSONAPI::MEDIA_TYPE
    }
  end
  let(:action) do
    ExampleAction.new(payload: payload, headers: headers, type: :photos)
  end

  describe "#includes" do
    subject { action.includes }

    context "with a two good and one bad" do
      let(:payload) do
        {
          "data" => nil,
          "include" => "active_photographer,active_photographer.posts.comments,active_photographer.posts"
        }
      end

      it "contains only the two good" do
        expect(subject).to eq([["active_photographer"], ["active_photographer", "posts"]])
      end
    end
  end

  describe "#fields" do
    subject { action.fields }

    context "with a two good and one bad" do
      let(:payload) do
        {
          "data" => nil,
          "fields" => "title,active_photographer.posts.comments.body,active_photographer.name"
        }
      end

      it "contains only the two good" do
        expect(subject).to eq([["title"], ["active_photographer", "name"]])
      end
    end
  end
end
