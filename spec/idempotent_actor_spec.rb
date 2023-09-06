# frozen_string_literal: true

class TestActor < IdempotentActor::Base
  def call
    state.called = true
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
  end
end
