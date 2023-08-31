# frozen_string_literal: true

module IdempontentActor
  # Base class for IdempotentActor
  module Base
    def self.included(base)
      base.extend(IdempontentActor::Core)
    end
  end
end
