require 'redis'
require 'rejson'

RClient = Redis.new(host: "localhost", port: 36379, db: 0)

class RedisStack
  class << self
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