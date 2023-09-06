# frozen_string_literal: true

require "idempotent_actor/support/loader"

module IdempotentActor
  # Core functionality
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods
    module ClassMethods
      def call(state = nil, **_args)
        # TODO: Merge args into state
        state = IdempotentActor::State.to_state(state)

        instance = new(state)
        instance.call

        state
      end
    end

    # :nodoc:
    def initialize(state)
      @state = state
    end

    def call; end

    # TODO: Rename this
    def recover; end

    def instance_call
      call
    end

    protected

    attr_reader :state
  end
end
