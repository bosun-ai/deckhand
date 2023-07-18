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
    Rails.logger.info "GithubAppController#event: #{params.inspect}"
    render json: { status: :ok }
  end
end
