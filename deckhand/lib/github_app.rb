require "uri"
require "net/http"
require "jwt"

class GithubApp
  class << self
    def client(installation_id)
      Octokit::Client.new(:access_token => get_access_token(installation_id))
    end

    def app_client
      Octokit::Client.new(bearer_token: get_jwt)
    end

    def get_access_token(installation_id)
      jwt = get_jwt
      response = Net::HTTP.post(
        URI("https://api.github.com/app/installations/#{installation_id}/access_tokens"),
        "",
        {
          "Accept" => "application/vnd.github+json",
          "Authorization" => "Bearer #{jwt}",
          "X-GitHub-Api-Version" => "2022-11-28",
        }
      )
      json = JSON.parse(response.body)
      json["token"]
    end

    def private_key
      @private_key ||= begin
          private_pem_b64 = ENV["GITHUB_APP_KEY"]
          private_pem = Base64.decode64(private_pem_b64)
          private_key = OpenSSL::PKey::RSA.new(private_pem)
        end
    end

    def get_jwt
      payload = {
        # issued at time
        iat: Time.now.to_i,
        # JWT expiration time (10 minute maximum)
        exp: 10.minutes.from_now.to_i,
        # GitHub App's identifier
        iss: ENV["GITHUB_APP_IDENTIFIER"],
      }
      JWT.encode(payload, private_key, "RS256")
    end
  end
end
