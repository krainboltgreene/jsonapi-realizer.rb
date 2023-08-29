# frozen_string_literal: true

require "spec_helper"

RSpec.describe JSONAPI::Realizer::VERSION do
  it "is a string" do
    expect(described_class).to be_a(String)
  end
end
