require "spec_helper"

RSpec.describe JSONAPI::Realizer::Action do
  let(:action) do
    Class.new(described_class) do
      def initialize(payload:, type:)
        @payload = payload
        @type = type
      end
    end.new(payload: payload, type: :photos)
  end

  describe "#includes" do
    subject { action.includes }

    context "with a two good and one bad" do
      let(:payload) do
        {
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
          "fields" => "title,active_photographer.posts.comments.body,active_photographer.name"
        }
      end

      it "contains only the two good" do
        expect(subject).to eq([["title"], ["active_photographer", "name"]])
      end
    end
  end
end
