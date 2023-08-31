# frozen_string_literal: true

module IdempontentActor
  # Core module for IdempotentActor
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods for IdempotentActor
    module ClassMethods
      def call(**args)
        puts "Called with #{args}"
      end
    end
  end
end
