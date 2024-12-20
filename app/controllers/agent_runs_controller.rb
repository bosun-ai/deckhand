class AgentRunsController < ApplicationController
  before_action :set_agent_run, only: %i[ show edit update destroy retry ]

  # GET /agent_runs or /agent_runs.json
  def index
    @agent_runs = AgentRun.root.order(created_at: 'DESC')
  end

  # GET /agent_runs/1 or /agent_runs/1.json
  def show; end

  # GET /agent_runs/new
  def new
    @agent_run = AgentRun.new
  end

  # GET /agent_runs/1/edit
  def edit; end

  # POST /agent_runs or /agent_runs.json
  def create
    @agent_run = AgentRun.new(agent_run_params)
    
    free_attributes = params[:agent_run].to_unsafe_h.slice(:arguments, :context, :output, :error)
    @agent_run.assign_attributes(free_attributes)

    respond_to do |format|
      if @agent_run.save
        format.html { redirect_to agent_run_url(@agent_run), notice: 'Agent run was successfully created.' }
        format.json { render :show, status: :created, location: @agent_run }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @agent_run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agent_runs/1 or /agent_runs/1.json
  def update
    respond_to do |format|
      if @agent_run.update(agent_run_params)
        format.html { redirect_to agent_run_url(@agent_run), notice: 'Agent run was successfully updated.' }
        format.json { render :show, status: :ok, location: @agent_run }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agent_run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agent_runs/1 or /agent_runs/1.json
  def destroy
    @agent_run.destroy

    respond_to do |format|
      format.html { redirect_to agent_runs_url, notice: 'Agent run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def retry
    @agent_run.retry!(nil)
    redirect_to agent_run_url(@agent_run, notice: "Initiated retry for agent.")
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_agent_run
    @agent_run = AgentRun.find(params[:id] || params[:agent_run_id])
  end

  # Only allow a list of trusted parameters through.
  def agent_run_params
    params.require(:agent_run)
      .permit(
        :id, :name, :started_at, :finished_at, :parent_id, :codebase_agent_service_id
      )
  end
end
