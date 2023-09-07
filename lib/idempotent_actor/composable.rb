# frozen_string_literal: true

module IdempotentActor
  # Playable functionality
  module Composable
    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(InstanceMethods)
    end

    # Class methods
    module ClassMethods
      def run(*actors, **options)
        runnables.push(actors: actors, **options)
      end

      def runnables
        @runnables ||= []
      end
    end

    # Instance methods for prepending
    module InstanceMethods
      def call
        self.class.runnables.each do |runnable|
          next unless callable?(runnable)

          actors = runnable[:actors]
          actors.each do |actor|
            try_call(actor)
          end
        end
      end

      private

      def callable?(runnable)
        if_statement = runnable[:if]

        return false if if_statement && !if_statement.call

        unless_statement = runnable[:unless]

        return false if unless_statement&.call

        true
      end

      def try_call(actor)
        return send(actor) if actor.is_a?(Symbol)
        return call_idempotent_actor(actor) if actor.is_a?(Class) && actor.ancestors.include?(IdempotentActor::Core)
        return actor.call(state) if actor.respond_to?(:call)

        raise ArgumentError, "Actor(#{actor}) is not callable"
      end

      def call_idempotent_actor(actor)
        isntance = actor.new(state)
        isntance.internal_call_do_not_use

        # TODO: shit for rollback and recovery
      end
    end
  end
end
