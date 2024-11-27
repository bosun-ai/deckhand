require 'redis_stack'

require 'redis'

RClient = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:36379/0'))
