# frozen_string_literal: true

RSpec.describe IdempotentActor::State do
  describe ".to_state" do
    it "returns the same object if it is already a state" do
      state = described_class.new
      expect(described_class.to_state(state)).to eq(state)
    end

    it "returns a new state if it is not already a state" do
      data = { foo: "bar" }
      state = described_class.to_state(data)
      expect(state).to be_a(described_class)
      expect(state.foo).to eq("bar")
    end
  end

  describe "#new" do
    it "works" do
      state = described_class.new
      expect(state).to be_a(described_class)
    end

    it "adds an errors array" do
      state = described_class.new
      expect(state.errors).to eq([])
    end
  end

  describe "#inspect" do
    it "works" do
      state = described_class.new
      expect(state.inspect).to eq("#<IdempotentActor::State {:errors=>[]}>")
    end
  end

  describe "#success?" do
    it "returns true if there are no errors" do
      state = described_class.new
      expect(state.success?).to be true
    end

    it "returns false if there are errors" do
      state = described_class.new
      state.errors << "foo"
      expect(state.success?).to be false
    end
  end

  describe "#failure?" do
    it "returns false if there are no errors" do
      state = described_class.new
      expect(state.failure?).to be false
    end

    it "returns true if there are errors" do
      state = described_class.new
      state.errors << "foo"
      expect(state.failure?).to be true
    end
  end

  describe "#errors" do
    it "works" do
      state = described_class.new
      expect(state.errors).to eq([])
    end

    it "is an array" do
      state = described_class.new
      expect(state.errors).to be_a(Array)
    end

    it "return errors that were added" do
      state = described_class.new
      state.errors << "foo"
      expect(state.errors).to eq(["foo"])
    end
  end

  describe "#merge" do
    it "works" do
      state = described_class.new(foo: "bar")
      other = described_class.new(baz: "qux")
      merged = state.merge(other)
      expect(merged).to be_a(described_class)
      expect(merged.foo).to eq("bar")
      expect(merged.baz).to eq("qux")
    end

    it "overwrites the original state" do
      state = described_class.new(foo: "bar")
      other = described_class.new(foo: "baz")
      merged = state.merge(other)
      expect(merged).to be_a(described_class)
      expect(merged.foo).to eq("baz")
    end
  end
end
