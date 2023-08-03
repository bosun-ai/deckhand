require "redis_stack"

require "redis"

if Rails.env.test?
  REDIS_URL = "redis://localhost:36379/0"
else
  REDIS_URL = ENV["REDIS_URL"] || "redis://localhost:36379/0"
end

RClient = Redis.new(url: REDIS_URL)
