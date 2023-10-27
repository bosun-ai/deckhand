require 'redis'
require 'rejson'
require 'active_graph/core/query'

# RClient = Redis.new(host: "localhost", port: 36379, db: 0)

class RedisStack
  GraphQuery = ActiveGraph::Core::Query

  class << self
    REDIS_GRAPH_VALUE_UNKNOWN = [0,
                                 REDIS_GRAPH_VALUE_NULL = 1,
                                 REDIS_GRAPH_VALUE_STRING = 2,
                                 REDIS_GRAPH_VALUE_INTEGER = 3,
                                 REDIS_GRAPH_VALUE_BOOLEAN = 4,
                                 REDIS_GRAPH_VALUE_DOUBLE = 5,
                                 REDIS_GRAPH_VALUE_ARRAY = 6,
                                 REDIS_GRAPH_VALUE_EDGE = 7,
                                 REDIS_GRAPH_VALUE_NODE = 8,
                                 REDIS_GRAPH_VALUE_PATH = 9,
                                 REDIS_GRAPH_VALUE_MAP = 10,
                                 REDIS_GRAPH_VALUE_POINT = 11].freeze

    REDIS_GRAPH_VALUE_TYPES = {
      REDIS_GRAPH_VALUE_UNKNOWN => 'UNKNOWN',
      REDIS_GRAPH_VALUE_NULL => 'NULL',
      REDIS_GRAPH_VALUE_STRING => 'STRING',
      REDIS_GRAPH_VALUE_INTEGER => 'INTEGER',
      REDIS_GRAPH_VALUE_BOOLEAN => 'BOOLEAN',
      REDIS_GRAPH_VALUE_DOUBLE => 'DOUBLE',
      REDIS_GRAPH_VALUE_ARRAY => 'ARRAY',
      REDIS_GRAPH_VALUE_EDGE => 'EDGE',
      REDIS_GRAPH_VALUE_NODE => 'NODE',
      REDIS_GRAPH_VALUE_PATH => 'PATH',
      REDIS_GRAPH_VALUE_MAP => 'MAP',
      REDIS_GRAPH_VALUE_POINT => 'POINT'
    }.freeze

    def graph_cache(graph_id)
      @graph_cache ||= {}
      @graph_cache[graph_id] ||= {
        properties: [],
        labels: [],
        relationship_types: []
      }
    end

    def serialize_graph_node(node)
      return nil if node.nil?

      serialized = '('
      serialized << node[:id] if node[:id]
      if (labels = node[:labels]) && labels.any?
        serialized << ':'
        serialized << labels.map { |label| label }.join(':')
      end

      if (properties = node[:properties]) && properties.any?
        serialized << ' {'
        serialized << properties.map { |key, value| "#{key}: #{serialize_value(value)}" }.join(', ')
        serialized << '}'
      end

      serialized << ')'
      serialized
    end

    # escapes a string for use in a redis command
    def escape_string_for_redis(value)
      value.gsub(/"/, '\"')
    end

    # serializes a ruby value into a redis literal
    def serialize_value(value)
      case value
      when String
        "\"#{escape_string_for_redis(value)}\""
      when Integer
        value.to_s
      when Float
        value.to_s
      when TrueClass
        'true'
      when FalseClass
        'false'
      when Array
        "[#{value.map { |v| serialize_value(v) }.join(', ')}]"
      when Hash
        "{#{value.map { |k, v| "#{k}: #{serialize_value(v)}" }.join(', ')}}"
      else
        raise "Unsupported value type #{value.class}"
      end
    end

    def serialize_graph_edge(edge)
      return nil if edge.nil?

      serialized = '-['
      serialized << edge[:id] if edge[:id]
      serialized << ":#{edge[:label]}" if edge[:label]
      if (properties = edge[:properties]) && properties.any?
        serialized << ' {'
        serialized << properties.map { |key, value| "#{key}: #{serialize_value(value)}" }.join(', ')
        serialized << '}'
      end
      serialized << ']->'
    end

    def graph_insert(graph_id, relationship)
      source = serialize_graph_node(relationship[:source])
      target = serialize_graph_node(relationship[:target])
      edge = serialize_graph_edge(relationship[:edge])

      serialized_relationship = "#{source}#{edge}#{target}"

      graph_query(graph_id, "CREATE #{serialized_relationship}")
    end

    def graph_insert_node(graph_id, node)
      graph_query(graph_id, "CREATE #{serialize_graph_node(node)}")
    end

    def graph_attach_new(graph_id, target, edge, node)
      match = {
        id: 'target',
        labels: target[:labels]
      }

      query = "MATCH #{serialize_graph_node(match)}"
      if (properties = target[:properties]) && properties.any?
        query << ' WHERE '
        query << properties.map { |key, value| "target.#{key} = #{serialize_value(value)}" }.join(' AND ')
      end

      query << "CREATE (target)#{serialize_graph_edge(edge)}#{serialize_graph_node(node)}"

      graph_query(graph_id, query)
    end

    def graph_simple_insert(graph_id, source, edge, target)
      graph_insert(graph_id,
                   source: { labels: [source] },
                   edge: { label: edge },
                   target: { labels: [target] })
    end

    def get_property_cache(graph_id, property_id)
      result = graph_cache(graph_id)[:properties][property_id]
      return result unless result.nil?

      cache = graph_query(graph_id, 'CALL db.propertyKeys()')
      cache.shift
      cache.pop
      cache = cache.first.map(&:first).map(&:second)
      # puts "Got property cache: #{cache.inspect}"
      graph_cache(graph_id)[:properties] = cache
      graph_cache(graph_id)[:properties][property_id]
    end

    def get_label_cache(graph_id, label_id)
      result = graph_cache(graph_id)[:labels][label_id]
      return result unless result.nil?

      cache = graph_query(graph_id, 'CALL db.labels()')
      cache.shift
      cache.pop
      cache = cache.first.map(&:first).map(&:second)
      # puts "Got label cache: #{cache.inspect}"
      graph_cache(graph_id)[:labels] = cache
      graph_cache(graph_id)[:labels][label_id]
    end

    def get_relationship_type_cache(graph_id, relationship_type_id)
      result = graph_cache(graph_id)[:relationship_types][relationship_type_id]
      return result unless result.nil?

      cache = graph_query(graph_id, 'CALL db.relationshipTypes()')
      cache.shift
      cache.pop
      cache = cache.first.map(&:first).map(&:second)
      # puts "Got relationship_type cache: #{cache.inspect}"
      graph_cache(graph_id)[:relationship_types] = cache
      graph_cache(graph_id)[:relationship_types][relationship_type_id]
    end

    def parse_redis_graph_properties(graph_id, properties)
      Hash[properties.map do |property|
             [get_property_cache(graph_id, property[0]), parse_redis_graph_result(graph_id, property[1..2])]
           end]
    end

    def parse_redis_graph_result(graph_id, result)
      type = result[0]
      value = result[1]
      case type
      when REDIS_GRAPH_VALUE_NODE
        {
          id: value[0],
          labels: value[1].map { |label_id| get_label_cache(graph_id, label_id) },
          properties: parse_redis_graph_properties(graph_id, value[2]),
          type: 'NODE'
        }
      when REDIS_GRAPH_VALUE_EDGE
        {
          id: value[0],
          label: get_relationship_type_cache(graph_id, value[1]),
          source: value[2],
          destination: value[3],
          properties: parse_redis_graph_properties(graph_id, value[4]),
          type: 'EDGE'
        }
      when REDIS_GRAPH_VALUE_STRING
        value
      when REDIS_GRAPH_VALUE_INTEGER
        value.to_i
      else
        raise "Unsupported type #{REDIS_GRAPH_VALUE_TYPES[type]}" if REDIS_GRAPH_VALUE_TYPES[type]

        raise "Unknown type #{type}"

      end
    end

    def delete_graph(graph_id)
      client.call('GRAPH.DELETE', graph_id)
      true
    rescue Redis::CommandError => e
      raise e unless e.message =~ /empty key/

      false
    end

    def graph_query(graph_id, query)
      client.call('GRAPH.QUERY', graph_id, query, '--compact')
    end

    def graph_match(graph_id, query)
      results = graph_query(graph_id, "MATCH #{query}")
      results.shift
      results.pop
      results = results.first
      results.map do |result|
        result.map do |column|
          # puts "Parsing column: #{column.inspect}"
          parse_redis_graph_result(graph_id, column)
        end
      end
    end

    VectorSimilaritySearchResult = Struct.new(:id, :score, :object, keyword_init: true)

    def create_json_vector_similarity_index(
      index_name,
      field_selector: nil,
      dimensions: nil,
      vector_field_name: 'vector_field'
    )
      # An index is created by executing a command with the following syntax:
      # FT.CREATE ... SCHEMA ... {field_name} VECTOR {algorithm} {count} [{attribute_name} {attribute_value} ...]
      client.call(
        'FT.CREATE', index_name,
        'ON', 'JSON',
        'SCHEMA', field_selector, 'as', vector_field_name,
        'VECTOR',
        'HNSW', '6',
        'TYPE', 'FLOAT32',
        'DIM', dimensions.to_s,
        'DISTANCE_METRIC', 'L2'
      )
    end

    def vector_similarity_search(index, vector, limit: 10, vector_field_name: 'vector_field')
      vector_blob = vector.pack('f*')
      results = RClient.call(
        'FT.SEARCH', index,
        "*=>[KNN #{limit} @#{vector_field_name} $BLOB]",
        'PARAMS', '2',
        'BLOB', vector_blob,
        'SORTBY', "__#{vector_field_name}_score",
        'DIALECT', '2'
      )

      results_count = results.first
      index = 1

      results_count.times.map do |_|
        id = results[index]
        index += 1
        result = results[index]
        index += 1

        VectorSimilaritySearchResult.new(
          id:,
          score: result[1].to_f,
          object: JSON.parse(result[3])
        )
      end
    end

    def client
      RClient
    end
  end
end
