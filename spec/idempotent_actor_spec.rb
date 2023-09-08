# frozen_string_literal: true

class TestActor < IdempotentActor::Base
  def call
    state.called = true
  end
end

class FalliableActor < IdempotentActor::Base
  def call
    fail!("Something went wrong")
  end
end

class FalliableActorSetsErrors < IdempotentActor::Base
  def call
    errors << "Something went wrong"
  end
end

RSpec.describe IdempotentActor do
  it "has a version number" do
    expect(IdempotentActor::VERSION).not_to be nil
  end

  context "basic usage" do
    it "sets called to true" do
      result = TestActor.call
      expect(result.called).to be true
    end

    it "sets called to true and keeps the extra state" do
      result = TestActor.call(called: false, gaming: :moment)
      expect(result.called).to be true
      expect(result.gaming).to eq :moment
    end
  end

  context "faliable usage" do
    it "sets success to false when calling fail!" do
      result = FalliableActor.call
      expect(result.success?).to be false
    end

    it "sets success to false when setting errors" do
      result = FalliableActorSetsErrors.call
      expect(result.success?).to be false
    end
  end
end
