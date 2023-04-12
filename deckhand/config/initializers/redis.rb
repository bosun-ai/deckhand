require 'redis'
require 'rejson'

RClient = Redis.new(host: "localhost", port: 36379, db: 0)