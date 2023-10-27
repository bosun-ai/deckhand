class CodebasesController < ApplicationController
  before_action :set_codebase, only: %i[show edit update destroy]

  # GET /codebases or /codebases.json
  def index
    @codebases = Codebase.all
  end

  # GET /codebases/1 or /codebases/1.json
  def show; end

  # GET /codebases/new
  def new
    @codebase = Codebase.new
  end

  # GET /codebases/1/edit
  def edit; end

  def discover_testing_infrastructure
    @codebase = Codebase.find(params[:codebase_id])
    thread = Thread.new do
      Rails.application.executor.wrap do
        @codebase.discover_testing_infrastructure
      end
    end

    redirect_to codebase_url(@codebase), notice: 'Discovering testing infrastructure for codebase.'
  end

  # POST /codebases or /codebases.json
  def create
    @codebase = Codebase.new(codebase_params)

    respond_to do |format|
      if @codebase.save
        # format.html { redirect_to codebase_url(@codebase), notice: "Codebase was successfully created." }
        format.html { redirect_to main_deck_url, notice: 'Codebase was successfully created.' }
        format.json { render :show, status: :created, location: @codebase }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @codebase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /codebases/1 or /codebases/1.json
  def update
    respond_to do |format|
      if @codebase.update(codebase_params)
        format.html { redirect_to codebase_url(@codebase), notice: 'Codebase was successfully updated.' }
        format.json { render :show, status: :ok, location: @codebase }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @codebase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codebases/1 or /codebases/1.json
  def destroy
    @codebase.destroy

    respond_to do |format|
      format.html { redirect_to codebases_url, notice: 'Codebase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_codebase
    @codebase = Codebase.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def codebase_params
    params.require(:codebase).permit(:name, :url)
  end
end
