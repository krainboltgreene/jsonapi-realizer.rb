require "spec_helper"

RSpec.describe Blankgem::VERSION do
  it "should be a string" do
    expect(Blankgem::VERSION).to be_kind_of(String)
  end
end
