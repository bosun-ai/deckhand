class GithubAppController < ApplicationController
  def github_app_callback
    Rails.logger.info "GithubAppController#github_app_callback: #{params.inspect}"
    render text: "Your repository has been set up. You can close this window now."
  end

  def github_app_setup
    Rails.logger.info "GithubAppController#github_app_setup: #{params.inspect}"
    render text: "Your repository has been set up. You can close this window now."
  end

  def github_app_event
    Rails.logger.info "GithubAppController#github_app_event: #{params.inspect}"
    render json: { status: :ok }
  end
end
