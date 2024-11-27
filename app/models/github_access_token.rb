class GithubAccessToken < ApplicationRecord
  belongs_to :codebase

  def expired?
    # token is expired after 24 hours
    (Time.zone.now - created_at) < 24.hours
  end
end
