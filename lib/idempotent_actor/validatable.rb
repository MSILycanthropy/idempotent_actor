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

      def output(name, type:, optional: false, default: nil)
        outputs[name] = { type: Array(type), optional: optional, default: default }
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

        result = call

        return if failure?

        default_outputs!
        check_output_requirements!
        check_output_types!

        result
      end

      private

      def default_inputs!
        self.class.inputs.each do |name, input|
          next if input[:default].nil?

          value = state.send(name)

          default = input[:default]
          default_value = extract_value(default)

          state.send("#{name}=", default_value) if value.nil?
        end
      end

      def default_outputs!
        self.class.outputs.each do |name, output|
          next if output[:default].nil?

          value = state.send(name)

          default = output[:default]
          default_value = extract_value(default)

          state.send("#{name}=", default_value) if value.nil?
        end
      end

      def check_input_requirements!
        self.class.inputs.each do |name, input|
          value = state.send(name)

          valid = required_and_present?(input, value)

          errors << "Input #{name} is required" unless valid
        end
      end

      def check_output_requirements!
        self.class.outputs.each do |name, output|
          value = state.send(name)

          valid = required_and_present?(output, value)

          errors << "Output #{name} is required" unless valid
        end
      end

      def check_input_types!
        self.class.inputs.each do |name, input|
          value = state.send(name)

          valid = valid_type?(input, value)

          errors << "Input #{name} must be one of #{input[:type]}" unless valid
        end
      end

      def check_output_types!
        self.class.outputs.each do |name, output|
          value = state.send(name)

          valid = valid_type?(output, value)

          errors << "Output #{name} must be one of #{output[:type]}" unless valid
        end
      end

      def required_and_present?(options, value)
        optional = options[:optional]
        required = extract_value(optional).is_a?(TrueClass)

        return true if required

        !value.nil?
      end

      def valid_type?(input, value)
        return true if input[:optional] && value.nil?

        input[:type].any? do |type|
          value.is_a?(type)
        end
      end

      def extract_value(thing)
        return thing unless thing.is_a?(Proc)

        thing.call(state)
      end
    end
  end
end
