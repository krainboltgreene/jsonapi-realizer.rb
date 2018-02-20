require "spec_helper"

RSpec.describe JSONAPI::Realizer::VERSION do
  it "should be a string" do
    expect(JSONAPI::Realizer::VERSION).to be_kind_of(String)
  end
end
