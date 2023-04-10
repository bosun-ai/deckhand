# Facts are knowledge we have about a topic
# They are stored in Redis and are indexed by embeddings
class Fact < ApplicationModel
  attribute :id, :content, :topic, :embeddings, :codebase_id

  validates :content, :topic, :codebase_id, presence: true

  def self.find(id)
    from_json RClient.json_get(id, ".")
  end

  def self.from_json(json)
    new JSON.parse(json)
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
    set_embeddings if embeddings.nil?

    RClient.json_set(id, ".", to_json)
  end

  private
  def set_id
    self.id = "fact:#{SecureRandom.uuid}"
  end

  def set_embeddings
    topic_hash = Digest::SHA256.hexdigest(topic)
    if embeddings = RClient.json_get("topic_embeddings_cache:#{topic_hash}", ".")
      self.embeddings = embeddings
    else
      embeddings = [Deckhand::Lm.embedding(topic)]
      RClient.json_set("topic_embeddings_cache:#{topic_hash}", ".", embeddings)
      self.embeddings = embeddings
    end
  end
end