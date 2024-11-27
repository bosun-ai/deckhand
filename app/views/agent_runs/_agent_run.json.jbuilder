json.extract! agent_run, :id, :name, :arguments, :context, :output, :finished_at, :parent_id, :created_at, :updated_at
json.url agent_run_url(agent_run, format: :json)
