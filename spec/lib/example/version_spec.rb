require "spec_helper"

describe Example::VERSION do
  it "should be a string" do
    expect(Example::VERSION).to be_kind_of(String)
  end
end
