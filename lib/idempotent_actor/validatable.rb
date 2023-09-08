# frozen_string_literal: true

module IdempotentActor
  # Input and Output functionality
  module Validatable
    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(InstanceMethods)
    end

    # Class methods
    module ClassMethods
      def input(name, type:, optional: false, default: nil)
        inputs[name] = { type: Array(type), optional: optional, default: default }
      end

      def output(name, type:)
        outputs[name] = { type: Array(type) }
      end

      def inputs
        @inputs ||= {}
      end

      def outputs
        @outputs ||= {}
      end
    end

    # Instance methods for prepending
    module InstanceMethods
      def internal_call_do_not_use
        default_inputs!
        check_input_requirements!
        check_input_types!

        return if failure?

        call
      end

      private

      def default_inputs!
        self.class.inputs.each do |name, input|
          next if input[:default].nil?

          value = state.send(name)

          state.send("#{name}=", input[:default]) if value.nil?
        end
      end

      def check_input_requirements!
        self.class.inputs.each do |name, input|
          value = state.send(name)

          valid = input_required_and_present?(input, value)

          errors << "Input #{name} is required" unless valid
        end
      end

      def check_input_types!
        self.class.inputs.each do |name, input|
          value = state.send(name)

          valid = input_valid?(input, value)

          errors << "Input #{name} must be one of #{input[:type]}" unless valid
        end
      end

      def input_required_and_present?(input, value)
        optional = input[:optional]
        optional_input = if optional.is_a?(Proc)
                           optional.call(state).is_a?(TrueClass)
                         else
                           optional.is_a?(TrueClass)
                         end

        return true if optional_input

        !value.nil?
      end

      def input_valid?(input, value)
        return true if input[:optional] && value.nil?

        input[:type].any? do |type|
          value.is_a?(type)
        end
      end
    end
  end
end
