require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
Dotenv::Railtie.load if %w[development test].include? ENV['RAILS_ENV']

module Deckhand
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    config.active_record.schema_format = :sql

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths += Dir[Rails.root / 'app' / 'agents']
    config.autoload_paths += Dir[Rails.root / 'app' / 'agents' / 'tools']
  end
end
