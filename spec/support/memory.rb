
module MemoryStore
  extend ActiveSupport::Concern

  def create
    assign_attributes(updated_at: Time.now, id: id || SecureRandom.uuid)
    self.class.const_get("STORE")[id] = self.class.const_get("ATTRIBUTES").inject({}) do |hash, key|
      hash.merge({ key => self.send(key) })
    end
  end

  class_methods do
    def fetch(id)
      self.new(self.const_get("STORE").fetch(id))
    end

    def all
      self.const_get("STORE").values.map(&method(:new))
    end
  end

  require_relative "memory/models/account"
  require_relative "memory/models/comment"
  require_relative "memory/models/photo"
  require_relative "memory/models/post"
  require_relative "memory/realizers/account_realizer"
  require_relative "memory/realizers/comment_realizer"
  require_relative "memory/realizers/photo_realizer"
  require_relative "memory/realizers/post_realizer"
end
