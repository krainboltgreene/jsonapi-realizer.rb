require "spec_helper"

RSpec.describe JSONAPI::Marshal::VERSION do
  it "should be a string" do
    expect(JSONAPI::Marshal::VERSION).to be_kind_of(String)
  end
end
