class AgentRunEventsController < ApplicationController
  before_action :set_agent_run_event, only: %i[ show edit update destroy ]

  def show
    render 'show'
  end

  def expanded
    @expanded = true
    show
  end

  def create
    agent_run = AgentRun.find(params[:agent_run_id])

    params[:events].each do |event|
      id = event[:id]
      started_at = event[:started_at]
      duration = event[:duration]
      type = event[:type]
      parent_event_id = event[:parent_event_id]
      content = event[:content].permit!.to_h

      agent_run.events.build(
        id:,
        started_at:,
        duration:,
        parent_event_id:,
        event: {
          "type" => type,
          "content" => content,
        }
      )
    end
    agent_run.save!

    render json: { status: 'ok' }
  end

  private
  
  def set_agent_run_event
    @agent_run_event = AgentRunEvent.find(params[:agent_run_event_id], params[:id])
  end
end