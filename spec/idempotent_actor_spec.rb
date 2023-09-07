# frozen_string_literal: true

class TestActor < IdempotentActor::Base
  def call
    state.called = true
  end
end

class TestComposableActor < IdempotentActor::Base
  run TestActor
  run :funny_method
  run ->(state) { state.among_us = :sus }

  def funny_method
    state.funny = { haha: 25 }
  end
end

RSpec.describe IdempotentActor do
  it "has a version number" do
    expect(IdempotentActor::VERSION).not_to be nil
  end

  context "basic usage" do
    it "works" do
      result = TestActor.call
      expect(result.called).to be true
    end

    it "works with state passed in" do
      result = TestActor.call(called: false, gaming: :moment)
      expect(result.called).to be true
      expect(result.gaming).to eq :moment
    end
  end

  context "composable usage" do
    it "runs the actor" do
      result = TestComposableActor.call
      expect(result.called).to be true
    end

    it "runs the method" do
      result = TestComposableActor.call
      expect(result.funny).to be_a Hash
      expect(result.funny[:haha]).to eq 25
    end

    it "runs the proc" do
      result = TestComposableActor.call
      expect(result.among_us).to eq :sus
    end
  end
end
