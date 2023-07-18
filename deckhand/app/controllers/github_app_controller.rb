class GithubAppController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    render plain: "Your repository has been set up. You can close this window now."
  end

  def setup
    installation_id = params[:installation_id]
    client = GithubApp.client(installation_id)
    repositories = client.list_app_installation_repositories.each do |repo|
      Rails.logger.info "GithubAppController#setup: repo: #{repo.inspect}"
      codebase = Codebase.find_or_create_by!(name: repo.full_name, url: repo.ssh_url, github_app_installation_id: installation_id)
    end

    redirect_to main_deck_url, notice: "Added new repositories"
  end

  def event
    Rails.logger.info "GithubAppController#event: #{params.inspect}"
    render json: { status: :ok }
  end
end
