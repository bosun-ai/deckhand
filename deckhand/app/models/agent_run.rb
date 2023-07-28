class AgentRun < ApplicationRecord
  belongs_to :parent, optional: true, class_name: 'AgentRun'
end
