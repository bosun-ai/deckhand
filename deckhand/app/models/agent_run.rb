class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
  has_many :children, class_name: 'AgentRun', foreign_key: 'parent_id', dependent: :destroy
  has_many :events, class_name: 'AgentRunEvent', dependent: :destroy

  before_validation :ensure_parent_ids

  def self.for_codebase(codebase)
    where("context->>'codebase_id' = ?", codebase.id.to_s)
  end

  def self.root
    where(parent: nil)
  end

  def success?
    finished_at && error.blank?
  end

  def duration
    ActiveSupport::Duration.build(finished_at - created_at)
  end

  def error=(error)
    error = {
      class: error.class.name,
      message: error.message,
      backtrace: error.backtrace
    }.as_json
    super(error)
  end

  def feed
    children.sort_by(&:created_at).reverse
  end

  private

  def ensure_parent_ids
    return if !parent_id || parent_ids.present?

    self.parent_ids = parent.parent_ids + [parent_id]
  end
end
