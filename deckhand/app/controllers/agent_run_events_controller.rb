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
      started_at = event[:started_at]
      duration = event[:duration]
      type = event[:type]
      content = event[:content].permit!.to_h

      agent_run.events.build(
        started_at:,
        duration:,
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