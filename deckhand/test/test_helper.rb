ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

RClient = Redis.new(host: "localhost", port: 36379, db: 14)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
