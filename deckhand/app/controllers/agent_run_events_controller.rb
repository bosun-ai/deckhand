class AgentRunEventsController < ApplicationController
  before_action :set_agent_run_event

  def show
    render 'show'
  end

  def expanded
    @expanded = true
    show
  end

  private
  
  def set_agent_run_event
    @agent_run_event = AgentRunEvent.find(params[:agent_run_event_id], params[:id])
  end
end