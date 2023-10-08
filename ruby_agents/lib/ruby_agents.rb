# frozen_string_literal: true

require_relative "ruby_agents/version"

# require all files in the ruby_agents/ directory and it's subdirectories

Dir[File.join(__dir__, "ruby_agents", "**/*.rb")].sort.each do |file|
  require file
end

module RubyAgents
  class Error < StandardError; end
  # Your code goes here...
end
