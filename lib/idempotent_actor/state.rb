# frozen_string_literal: true

require "ostruct"

module IdempotentActor
  # Thin wrapper around OpenStruct
  class State < OpenStruct
    def self.to_state(data)
      return data if data.is_a?(State)

      new(data.to_h)
    end

    def initialize(data = {})
      data[:errors] = []

      super(data)
    end

    def inspect
      "#<#{self.class.name} #{to_h.inspect}>"
    end

    def success?
      !failure?
    end

    def failure?
      errors.any?
    end

    def errors
      @errors ||= []
    end
  end
end
