require "test_helper"

class FactTest < ActiveSupport::TestCase
  test "creating and finding a fact by id" do
    fact = Fact.new(content: "hello", topic: "test", codebase_id: "test")
    fact.save!
    retrieved_fact = Fact.find(fact.id)
    assert_equal(fact, retrieved_fact)
  end
end
