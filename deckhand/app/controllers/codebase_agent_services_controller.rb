class CodebaseAgentServicesController < ApplicationController
  before_action :set_codebase_agent_service, only: %i[ show edit update destroy ]

  # GET /codebase_agent_services or /codebase_agent_services.json
  def index
    @codebase_agent_services = CodebaseAgentService.all
  end

  # GET /codebase_agent_services/1 or /codebase_agent_services/1.json
  def show
  end

  # GET /codebase_agent_services/new
  def new
    @codebase_agent_service = CodebaseAgentService.new
  end

  # GET /codebase_agent_services/1/edit
  def edit
  end

  # POST /codebase_agent_services or /codebase_agent_services.json
  def create
    @codebase_agent_service = CodebaseAgentService.new(codebase_agent_service_params)

    respond_to do |format|
      if @codebase_agent_service.save
        format.html { redirect_to codebase_agent_service_url(@codebase_agent_service), notice: "Codebase agent service was successfully created." }
        format.json { render :show, status: :created, location: @codebase_agent_service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @codebase_agent_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /codebase_agent_services/1 or /codebase_agent_services/1.json
  def update
    respond_to do |format|
      if @codebase_agent_service.update(codebase_agent_service_params)
        format.html { redirect_to codebase_agent_service_url(@codebase_agent_service), notice: "Codebase agent service was successfully updated." }
        format.json { render :show, status: :ok, location: @codebase_agent_service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @codebase_agent_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codebase_agent_services/1 or /codebase_agent_services/1.json
  def destroy
    @codebase_agent_service.destroy!

    respond_to do |format|
      format.html { redirect_to codebase_agent_services_url, notice: "Codebase agent service was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_codebase_agent_service
    @codebase_agent_service = CodebaseAgentService.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def codebase_agent_service_params
    params.require(:codebase_agent_service).permit(:name, :configuration, :state, :enabled)
  end
end
