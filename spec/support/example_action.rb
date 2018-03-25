class ExampleAction < JSONAPI::Realizer::Action
  def initialize(payload:, headers:, type:, scope: nil)
    @type = type
    super(payload: payload, headers: headers, scope: scope)
  end
end
