# Facts are knowledge we have about a topic
# They are stored in Redis and are indexed by topic_embedding
class Fact < ApplicationModel
  attribute :id, :content, :topic, :topic_embedding, :codebase_id

  validates :content, :topic, :codebase_id, presence: true

  def self.create_index
    RedisStack.create_json_vector_similarity_index(
      'fact_topic_index',
      field_selector: '$.topic_embedding',
      dimensions: 1536
    )
  end

  def self.search_by_topic(search_term)
    embedding = Deckhand::Lm.cached_embedding(search_term)
    RedisStack.vector_similarity_search('fact_topic_index', embedding).each do |result|
      result[:object] = from_json(result[:object])
    end
  end

  def self.find(id)
    from_json RClient.json_get(id, '$').first
  end

  def self.from_json(json)
    new(json)
  end

  def self.all
    RClient.keys('fact:*').map do |id|
      find(id)
    end
  end

  def self.delete_all
    RClient.del(*RClient.keys('fact:*'))
  end

  def save!
    raise 'Invalid Fact' unless valid?

    set_id if id.nil?
    set_topic_embedding if topic_embedding.nil?

    RClient.json_set(id, '$', as_json)
  end

  private

  def set_id
    self.id = "fact:#{SecureRandom.uuid}"
  end

  def set_topic_embedding
    self.topic_embedding = Deckhand::Lm.cached_embedding(topic)
  end
end
