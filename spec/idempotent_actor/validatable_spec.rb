# frozen_string_literal: true

class TestValidatableActor < IdempotentActor::Base
  input :name, type: String, optional: true
  input :age, type: Integer
  input :cool, type: [TrueClass, FalseClass], default: false

  output :real_name, type: String, optional: true
  output :real_age, type: Integer
  output :real_cool, type: [TrueClass, FalseClass], default: false

  def call
    state.real_name = if state.cool
                        "Cool #{state.name}"
                      else
                        state.name
                      end

    state.real_age = state.age unless state.cool
  end
end

class TestValidatableProcActor < IdempotentActor::Base
  input :name, type: String, optional: ->(state) { state.age > 25 }
  input :age, type: Integer
  input :cool, type: [TrueClass, FalseClass], default: ->(state) { state.age > 25 }

  output :real_name, type: String, optional: true
  output :real_age, type: Integer
  output :real_cool, type: [TrueClass, FalseClass], default: ->(state) { state.age > 25 }

  def call
    state.real_name = if state.cool
                        "Cool #{state.name}"
                      else
                        state.name
                      end

    state.real_age = state.age
  end
end

class TestInvalidOutputsActor < IdempotentActor::Base
  output :real_name, type: String
  output :real_age, type: Integer

  def call
    state.real_name = 123
    state.real_age = "123"
  end
end

class TestMissingOutputsActor < IdempotentActor::Base
  input :age, type: Integer

  output :real_name, type: String, optional: ->(state) { state.age > 25 }

  def call; end
end

RSpec.describe IdempotentActor do # rubocop:disable Metrics/BlockLength
  context "validatable usage" do # rubocop:disable Metrics/BlockLength
    it "calls default_inputs! before running the actor" do
      expect_any_instance_of(TestValidatableActor).to receive(:default_inputs!)

      TestValidatableActor.call(name: "Bob", age: 25)
    end

    it "calls check_input_requirements! before running the actor" do
      expect_any_instance_of(TestValidatableActor).to receive(:check_input_requirements!)

      TestValidatableActor.call(name: "Bob", age: 25)
    end

    it "calls check_input_types! before running the actor" do
      expect_any_instance_of(TestValidatableActor).to receive(:check_input_types!)

      TestValidatableActor.call(name: "Bob", age: 25)
    end

    it "calls default_outputs! before running the actor" do
      expect_any_instance_of(TestValidatableActor).to receive(:default_outputs!)

      TestValidatableActor.call(name: "Bob", age: 25)
    end

    it "calls check_output_requirements! before running the actor" do
      expect_any_instance_of(TestValidatableActor).to receive(:check_output_requirements!)

      TestValidatableActor.call(name: "Bob", age: 25)
    end

    it "calls check_output_types! before running the actor" do
      expect_any_instance_of(TestValidatableActor).to receive(:check_output_types!)

      TestValidatableActor.call(name: "Bob", age: 25)
    end

    context "default inputs" do
      it "sets default values" do
        result = TestValidatableActor.call(name: "Bob", age: 25)

        expect(result.cool).to be false
      end

      it "sets default values (proc)" do
        result = TestValidatableProcActor.call(name: "Bob", age: 28)

        expect(result.cool).to be true
      end
    end

    context "with valid input" do
      it "succesfully runs the actor" do
        result = TestValidatableActor.call(name: "Bob", age: 25)

        expect(result.success?).to be true
        expect(result.real_name).to eq "Bob"
      end

      it "keeps the inputs in state" do
        result = TestValidatableActor.call(name: "Bob", age: 25)
        expect(result.name).to eq "Bob"
        expect(result.age).to eq 25
      end

      context "with optional inputs" do
        it "runs the actor with missing inputs" do
          result = TestValidatableActor.call(age: 25)
          expect(result.name).to be nil
          expect(result.success?).to be true
        end

        it "runs the actor with missing inputs (proc)" do
          result = TestValidatableProcActor.call(age: 28)
          expect(result.name).to be nil
          expect(result.success?).to be true
        end
      end
    end

    context "with invalid input" do
      it "fails to run the actor with invalid types (singular)" do
        result = TestValidatableActor.call(name: "Bob", age: "25")
        expect(result.errors).to eq ["Input age must be one of [Integer]"]
        expect(result.success?).to be false
      end

      it "fails to run the actor with invalid types (multiple)" do
        result = TestValidatableActor.call(name: "Bob", age: "25", cool: "true")
        expect(result.errors).to eq [
          "Input age must be one of [Integer]",
          "Input cool must be one of [TrueClass, FalseClass]"
        ]
        expect(result.success?).to be false
      end

      context "with optional inputs" do
        it "fails to run the actor with missing inputs (proc)" do
          result = TestValidatableProcActor.call(age: 13)
          expect(result.name).to be nil
          expect(result.success?).to be false
        end
      end
    end

    context "default outputs" do
      it "sets default values" do
        result = TestValidatableActor.call(name: "Bob", age: 25)
        expect(result.real_cool).to be false
      end

      it "sets default values (proc)" do
        result = TestValidatableProcActor.call(name: "Bob", age: 28)
        expect(result.real_cool).to be true
      end
    end

    context "with invalid output" do
      it "fails to run the actor with invalid types (multiple)" do
        result = TestInvalidOutputsActor.call(name: "Bob", age: 25)
        expect(result.errors).to eq [
          "Output real_name must be one of [String]",
          "Output real_age must be one of [Integer]"
        ]
        expect(result.success?).to be false
      end
    end

    context "with valid output" do
      it "succesfully runs the actor" do
        result = TestValidatableActor.call(name: "Bob", age: 25)
        expect(result.success?).to be true
        expect(result.real_name).to eq "Bob"
      end

      it "keeps the outputs in state" do
        result = TestValidatableActor.call(name: "Bob", age: 25)
        expect(result.real_name).to eq "Bob"
        expect(result.real_age).to eq 25
      end

      context "with optional outputs" do
        it "runs the actor with missing outputs" do
          result = TestValidatableActor.call(age: 25)
          expect(result.real_name).to be nil
          expect(result.success?).to be true
        end

        it "runs the actor with missing outputs (proc)" do
          result = TestMissingOutputsActor.call(age: 28)
          expect(result.real_name).to be nil
          expect(result.success?).to be true
        end
      end
    end
  end
end
