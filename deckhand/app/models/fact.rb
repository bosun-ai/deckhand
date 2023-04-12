# Facts are knowledge we have about a topic
# They are stored in Redis and are indexed by topic_embedding
class Fact < ApplicationModel
  attribute :id, :content, :topic, :topic_embedding, :codebase_id

  validates :content, :topic, :codebase_id, presence: true

  def self.create_index
    # An index is created by executing a command with the following syntax:
    # FT.CREATE ... SCHEMA ... {field_name} VECTOR {algorithm} {count} [{attribute_name} {attribute_value} ...]
    RClient.call(
      "FT.CREATE", "fact_topic_index",
      "ON", "JSON",
      "SCHEMA", "$.topic_embedding", "as", "topic_embedding",
      "VECTOR",
      "HNSW", "6",
      "TYPE", "FLOAT32",
      "DIM", "1536",
      "DISTANCE_METRIC", "L2"
    )
  end

  TopicSearchResult = Struct.new(:id, :score, :object, keyword_init: true)

  def self.search_by_topic(search_term)
    embedding = Deckhand::Lm.cached_embedding(search_term)
    embedding_blob = embedding.pack("f*")
    results = RClient.call(
      "FT.SEARCH", "fact_topic_index",
      "*=>[KNN 10 @topic_embedding $BLOB]",
      "PARAMS", "2",
      "BLOB", embedding_blob,
      "SORTBY", "__topic_embedding_score",
      "DIALECT", "2",
    )

    results_count = results.first
    index = 1
    
    results_count.times.map do |_|
      id = results[index]
      index += 1
      result = results[index]
      index += 1

      TopicSearchResult.new(
        id: id,
        score: result[1].to_f,
        object: from_json(JSON.parse(result[3]))
      )
    end
  end

  def self.find(id)
    from_json RClient.json_get(id, "$").first
  end

  def self.from_json(json)
    new(json)
  end

  def self.all
    RClient.keys("fact:*").map do |id|
      find(id)
    end
  end

  def self.delete_all
    RClient.del(*RClient.keys("fact:*"))
  end

  def save!
    raise "Invalid Fact" unless valid?

    set_id if id.nil?
    set_topic_embedding if topic_embedding.nil?

    RClient.json_set(id, "$", as_json)
  end

  private
  def set_id
    self.id = "fact:#{SecureRandom.uuid}"
  end

  def set_topic_embedding
    self.topic_embedding = Deckhand::Lm.cached_embedding(topic)
  end
end