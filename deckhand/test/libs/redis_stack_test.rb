require "test_helper"

class RedisStackTest < ActiveSupport::TestCase
  setup do
    RedisStack.delete_graph('MotoGP')
    RedisStack.delete_graph('demo')
    RedisStack.graph_query "MotoGP", "CREATE (:Rider {name:'Valentino Rossi'})-[:rides]->(:Team {name:'Yamaha'}), (:Rider {name:'Dani Pedrosa'})-[:rides]->(:Team {name:'Honda'}), (:Rider {name:'Andrea Dovizioso'})-[:rides]->(:Team {name:'Ducati'})"
    RedisStack.graph_query "demo", "CREATE (:plant {name: 'Tree'})-[:GROWS {season: 'Autumn'}]->(:fruit {name: 'Apple'})"
  end

  test "it can execute match queries on demo" do
    results = RedisStack.graph_match "demo", "(a)-[e]->(b) RETURN a, e, b.name"
    assert_equal 1, results.length
    result = results[0]
    assert_equal 3, result.length
    subject = result[0]
    assert_equal("NODE", subject[:type])
    assert_equal("plant", subject[:labels][0])
    assert_equal("Tree", subject[:properties]['name'])
    edge = result[1]
    assert_equal("EDGE", edge[:type])
    assert_equal("GROWS", edge[:label])
    assert_equal("Autumn", edge[:properties]['season'])
    object = result[2]
    assert_equal("Apple", object)
  end

  test "it can execute match queries on MotoGP" do
    results = RedisStack.graph_match "MotoGP", "(r:Rider)-[:rides]->(t:Team) WHERE t.name = 'Yamaha' RETURN r.name, t.name"
    assert_equal(results[0], ["Valentino Rossi", "Yamaha"])
  end

  test "it can return integers" do
    results = RedisStack.graph_match "MotoGP", "(r:Rider)-[:rides]->(t:Team {name:'Ducati'}) RETURN count(r)"
    assert_equal(1, results[0][0])
  end
  
  test "it can insert relationships" do
    a = "ID#{SecureRandom.hex(10)}"
    b = "ID#{SecureRandom.hex(10)}"

    RedisStack.graph_simple_insert("test", a, "relates_to", b)

    results = RedisStack.graph_match "test", "(a:#{a})-[e]->(b) RETURN a, e, b"

    assert_equal 1, results.length
    result = results[0]
    assert_equal 3, result.length
    subject = result[0]
    assert_equal("NODE", subject[:type])
    assert_equal(a, subject[:labels][0])
    edge = result[1]
    assert_equal("EDGE", edge[:type])
    assert_equal("relates_to", edge[:label])
    object = result[2]
    assert_equal("NODE", object[:type])
    assert_equal(b, object[:labels][0])
  end

  test "it can create new nodes without relationships" do
    a = "ID#{SecureRandom.hex(10)}"

    node_a = { labels: [a], properties: { name: '"A"' } }

    RedisStack.graph_insert_node("test", node_a)

    results = RedisStack.graph_match "test", "(a:#{a}) RETURN a"

    assert_equal 1, results.length
    result = results[0]
    assert_equal 1, result.length
    subject = result[0]
    assert_equal("NODE", subject[:type])
    assert_equal(a, subject[:labels][0])
  end

  test "can create relationships to existing nodes" do
    a = "ID#{SecureRandom.hex(10)}"
    b = "ID#{SecureRandom.hex(10)}"

    node_a = { labels: [a], properties: { name: '"A"' } }
    node_b = { labels: [b], properties: { name: '"B"' } }

    RedisStack.graph_insert_node("test", node_a)
    RedisStack.graph_attach_new("test", node_a, { label: "relates_to", properties: { really: '"REALLY"'} }, node_b)

    results = RedisStack.graph_match "test", "(a:#{a})-[e]->(b) RETURN a, e, b"

    assert_equal 1, results.length
    result = results[0]
    assert_equal 3, result.length
    subject = result[0]
    assert_equal("NODE", subject[:type])
    assert_equal(a, subject[:labels][0])
    edge = result[1]
    assert_equal("EDGE", edge[:type])
    assert_equal("relates_to", edge[:label])
    object = result[2]
    assert_equal("NODE", object[:type])
    assert_equal(b, object[:labels][0])
  end
end
