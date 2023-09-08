# frozen_string_literal: true

require_relative "idempotent_actor/version"

require "idempotent_actor/core"
require "idempotent_actor/composable"
require "idempotent_actor/validatable"

# IdempotentActor
module IdempotentActor
  class Error < StandardError; end

  class Base
    include IdempotentActor::Validatable
    include IdempotentActor::Core
    include IdempotentActor::Composable
  end
end
