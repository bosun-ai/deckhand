class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
  has_many :children, class_name: 'AgentRun', foreign_key: 'parent_id'

  def self.root
    where(parent: nil)
  end

  def success?
    !output.nil?
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
end
