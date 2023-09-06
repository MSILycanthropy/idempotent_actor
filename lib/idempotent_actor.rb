# frozen_string_literal: true

require_relative "idempotent_actor/version"

require "idempotent_actor/core"

# IdempotentActor
module IdempotentActor
  class Error < StandardError; end
  # Your code goes here...

  class Base
    include IdempotentActor::Core
  end
end
