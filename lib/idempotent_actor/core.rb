# frozen_string_literal: true

require "idempotent_actor/support/loader"

module IdempotentActor
  # Core functionality
  module Core
    class Failure < StandardError; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods
    module ClassMethods
      def call(state = nil, **args)
        state = IdempotentActor::State.to_state(state).merge(args)

        instance = new(state)
        instance.internal_call_do_not_use

        state
      rescue Failure => e
        state.errors << e.message

        state
      end

      def recover(state = nil, **args)
        state = IdempotentActor::State.to_state(state).merge(args)

        instance = new(state)
        instance.recover

        state
      end
    end

    # :nodoc:
    def initialize(state)
      @state = state
    end

    def call; end

    def recover; end

    def fail!(message)
      raise Failure, message
    end

    def method_missing(method_name, *args, &block)
      return state.send(method_name, *args, &block) if state.respond_to?(method_name)

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      state.respond_to?(method_name, include_private) || super
    end

    # This lets us avoid the `super` call in the `call` method when we define it
    def internal_call_do_not_use
      call
    end

    def internal_recover_do_not_use
      recover
    end

    protected

    attr_reader :state
  end
end
