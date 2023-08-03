class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
  has_many :children, class_name: 'AgentRun', foreign_key: 'parent_id', dependent: :destroy
  has_many :events, class_name: "AgentRunEvent", dependent: :destroy

  before_validation :ensure_parent_ids

  def self.root
    where(parent: nil)
  end

  def success?
    !output.nil?
  end

  def duration
    ActiveSupport::Duration.build(finished_at - created_at)
  end

  def arguments
    JSON.parse(attributes['arguments'])
  end

  def context
    JSON.parse(attributes['context'])
  end

  def output
    JSON.parse(attributes['output']) if attributes['output']
  end

  def feed
    children.sort_by(&:created_at).reverse
  end

  def parent_ids
    JSON.parse(attributes['parent_ids'] || '[]')
  end

  private

  def ensure_parent_ids
    return if !parent_id || !parent_ids.blank?
    self.parent_ids = JSON.dump(parent.parent_ids + [parent_id])
  end
end
