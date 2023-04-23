require 'redis'
require 'rejson'

RClient = Redis.new(host: "localhost", port: 36379, db: 0)

class RedisStack
  class << self
    REDIS_GRAPH_VALUE_UNKNOWN = 0,
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
    REDIS_GRAPH_VALUE_POINT = 11

    REDIS_GRAPH_VALUE_TYPES = {
      REDIS_GRAPH_VALUE_UNKNOWN => "UNKNOWN",
      REDIS_GRAPH_VALUE_NULL => "NULL",
      REDIS_GRAPH_VALUE_STRING => "STRING",
      REDIS_GRAPH_VALUE_INTEGER => "INTEGER",
      REDIS_GRAPH_VALUE_BOOLEAN => "BOOLEAN",
      REDIS_GRAPH_VALUE_DOUBLE => "DOUBLE",
      REDIS_GRAPH_VALUE_ARRAY => "ARRAY",
      REDIS_GRAPH_VALUE_EDGE => "EDGE",
      REDIS_GRAPH_VALUE_NODE => "NODE",
      REDIS_GRAPH_VALUE_PATH => "PATH",
      REDIS_GRAPH_VALUE_MAP => "MAP",
      REDIS_GRAPH_VALUE_POINT => "POINT"
    }

    def graph_cache(graph_id)
      @graph_cache ||= {}
      @graph_cache[graph_id] ||= {
        properties: [],
        labels: [],
        relationship_types: []
      }
    end

    def get_property_cache(graph_id, property_id)
      result = graph_cache(graph_id)[:properties][property_id]
      return result unless result.nil?

      cache = graph_query(graph_id, "CALL db.propertyKeys()")
      header = cache.shift
      statistics = cache.pop
      cache = cache.first.map(&:first).map(&:second)
      # puts "Got property cache: #{cache.inspect}"
      graph_cache(graph_id)[:properties] = cache
      graph_cache(graph_id)[:properties][property_id]
    end

    def get_label_cache(graph_id, label_id)
      result = graph_cache(graph_id)[:labels][label_id]
      return result unless result.nil?

      cache = graph_query(graph_id, "CALL db.labels()")
      header = cache.shift
      statistics = cache.pop
      cache = cache.first.map(&:first).map(&:second)
      # puts "Got label cache: #{cache.inspect}"
      graph_cache(graph_id)[:labels] = cache
      graph_cache(graph_id)[:labels][label_id]
    end

    def get_relationship_type_cache(graph_id, relationship_type_id)
      result = graph_cache(graph_id)[:relationship_types][relationship_type_id]
      return result unless result.nil?

      cache = graph_query(graph_id, "CALL db.relationshipTypes()")
      header = cache.shift
      statistics = cache.pop
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
          labels: value[1].map {|label_id| get_label_cache(graph_id, label_id)},
          properties: parse_redis_graph_properties(graph_id, value[2]),
          type: "NODE"
        }
      when REDIS_GRAPH_VALUE_EDGE
        {
          id: value[0],
          label: get_relationship_type_cache(graph_id, value[1]),
          source: value[2],
          destination: value[3],
          properties: parse_redis_graph_properties(graph_id, value[4]),
          type: "EDGE"
        }
      when REDIS_GRAPH_VALUE_STRING
        value
      else
        if REDIS_GRAPH_VALUE_TYPES[type]
          raise "Unsupported type #{REDIS_GRAPH_VALUE_TYPES[type]}"
        else
          raise "Unknown type #{type}"
        end
      end
    end

    def delete_graph(graph_id)
      client.call("GRAPH.DELETE", graph_id)
      true
    rescue Redis::CommandError => e
      if e.message =~ /empty key/
        false
      else
        raise e
      end
    end

    def graph_query(graph_id, query)
      client.call("GRAPH.QUERY", graph_id, query, "--compact")
    end

    def graph_match(graph_id, query)
      results = graph_query(graph_id, "MATCH #{query}")
      header = results.shift
      statistics = results.pop
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
      vector_field_name: "vector_field"
    )
      # An index is created by executing a command with the following syntax:
      # FT.CREATE ... SCHEMA ... {field_name} VECTOR {algorithm} {count} [{attribute_name} {attribute_value} ...]
      client.call(
        "FT.CREATE", index_name,
        "ON", "JSON",
        "SCHEMA", field_selector, "as", vector_field_name,
        "VECTOR",
        "HNSW", "6",
        "TYPE", "FLOAT32",
        "DIM", dimensions.to_s,
        "DISTANCE_METRIC", "L2"
      )
    end

    def vector_similarity_search(index, vector, limit: 10, vector_field_name: "vector_field")
      vector_blob = vector.pack("f*")
      results = RClient.call(
        "FT.SEARCH", index,
        "*=>[KNN #{limit} @#{vector_field_name} $BLOB]",
        "PARAMS", "2",
        "BLOB", vector_blob,
        "SORTBY", "__#{vector_field_name}_score",
        "DIALECT", "2",
      )

      results_count = results.first
      index = 1
      
      results_count.times.map do |_|
        id = results[index]
        index += 1
        result = results[index]
        index += 1

        VectorSimilaritySearchResult.new(
          id: id,
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