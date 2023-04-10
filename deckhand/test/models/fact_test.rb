require "test_helper"

class FactTest < ActiveSupport::TestCase
  setup do
    Fact.delete_all
  end

  test "creating and finding a fact by id" do
    fact = Fact.new(content: "hello", topic: "test", codebase_id: "test")
    fact.save!
    retrieved_fact = Fact.find(fact.id)
    assert_equal(fact, retrieved_fact)
  end

  test "new facts are embedded" do
    fact = Fact.new(content: "hello", topic: "unit tests", codebase_id: "test")
    fact.save!
    assert_equal(1536, fact.embeddings.first.count)
  end

  test "Finding facts by topic similarity" do
    fact1 = Fact.new(content: "hello", topic: "unit tests", codebase_id: "test")
    fact1.save!

    fact2 = Fact.new(content: "hello", topic: "activerecord models", codebase_id: "test")
    fact2.save!

    retrieved_facts = Fact.find_by_topic("testing")
    assert_equal([fact1, fact2], retrieved_facts)

    retrieved_facts = Fact.find_by_topic("databases")
    assert_equal([fact2, fact1], retrieved_facts)
  end
end
