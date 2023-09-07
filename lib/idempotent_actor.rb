# frozen_string_literal: true

require_relative "idempotent_actor/version"

require "idempotent_actor/core"
require "idempotent_actor/composable"

# IdempotentActor
module IdempotentActor
  class Error < StandardError; end
  # Your code goes here...

  class Base
    include IdempotentActor::Core
    include IdempotentActor::Composable
  end
end
