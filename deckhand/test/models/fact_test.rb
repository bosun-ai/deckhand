require 'test_helper'

class FactTest < ActiveSupport::TestCase
  setup do
    Fact.delete_all
  end

  test 'creating and finding a fact by id' do
    fact = Fact.new(content: 'hello', topic: 'test', codebase_id: 'test')
    fact.save!
    retrieved_fact = Fact.find(fact.id)
    assert_equal(fact, retrieved_fact)
  end

  test 'new facts are embedded' do
    fact = Fact.new(content: 'hello', topic: 'unit tests', codebase_id: 'test')
    fact.save!
    assert_equal(1536, fact.topic_embedding.count)
  end

  test 'Searching facts by topic similarity' do
    fact1 = Fact.new(content: 'hello', topic: 'unit tests', codebase_id: 'test')
    fact1.save!

    fact2 = Fact.new(content: 'hello', topic: 'database models', codebase_id: 'test')
    fact2.save!

    retrieved_facts = Fact.search_by_topic('unit tests')
    assert_equal(retrieved_facts.map(&:id), [fact1.id, fact2.id])

    retrieved_facts = Fact.search_by_topic('active record models')
    assert_equal(retrieved_facts.map(&:id), [fact2.id, fact1.id])

    retrieved_facts = Fact.search_by_topic('testing')
    assert_equal(retrieved_facts.map(&:id), [fact1.id, fact2.id])

    retrieved_facts = Fact.search_by_topic('relational')
    assert_equal(retrieved_facts.map(&:id), [fact2.id, fact1.id])
  end
end
