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
    # self.embeddings = Embeddings.new(content).embeddings
  end
end