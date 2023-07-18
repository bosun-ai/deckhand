class GithubAppController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    render plain: "Your repository has been set up. You can close this window now."
  end

  def setup
    installation_id = params[:installation_id]
    Codebase.create_from_github_installation_id!(installation_id)

    redirect_to main_deck_url, notice: "Added new repositories"
  end

  def event
    installation = params[:installation]
    repo_name = params.dig(:repository, :full_name)
    
    if installation.present?
      codebase = Codebase.find_by(github_app_installation_id: installation[:id], name: repo_name)
      if codebase
        codebase.process_event(params)
      end
    end

    render json: { status: :ok }
  end
end
