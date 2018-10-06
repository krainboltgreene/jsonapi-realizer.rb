require("spec_helper")

RSpec.describe(JSONAPI::Realizer::Resource) do

  describe ".register" do
    subject {JSONAPI::Realizer::Resource.register(resource_class: "Test", model_class: "test", adapter: :a, type: "a")}
    context "with something already owning that type" do
      before do
        JSONAPI::Realizer::Resource.register(resource_class: "Test", model_class: "test", adapter: :a, type: "a")
      end

      it "raises an exception" do
        expect {subject}.to(raise_exception(JSONAPI::Realizer::Error::DuplicateRegistration))
      end
    end
  end
end
