source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1'

gem 'dotenv-rails', groups: %i[development test]

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'
# gem 'falcon'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

gem 'vite_rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'
gem 'rejson-rb', git: 'https://github.com/tinco/rejson-rb.git', branch: 'main'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'async-io'
gem 'async-process'

gem 'ansi-to-html'

gem 'activegraph'
gem 'ruby-openai'

gem 'faraday-retry'
gem 'jwt'
gem 'kramdown'
gem 'kramdown-parser-gfm'
gem 'kramdown-syntax-coderay'
gem 'octokit'

gem 'appsignal'
gem 'liquid'

gem 'with_advisory_lock'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # Linting
  gem 'brakeman', '~> 6.0', require: false
  gem 'bundle-audit', '~> 0.1.0', require: false
  gem 'rubocop', '~> 1.57', require: false
  gem 'rubocop-rails', '~> 2.22', require: false
  gem "rubocop-performance", "~> 1.19", require: false
  gem "rubocop-rake", "~> 0.6.0", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'rufo'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'mocha', require: false
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tailwindcss-rails', '~> 2.0'

# gem "dockerfile-rails", ">= 1.5", :group => :development

gem 'opentelemetry-instrumentation-all', '~> 0.50.1'
gem 'opentelemetry-sdk', '~> 1.3'

gem 'opentelemetry-exporter-otlp', '~> 0.26.1'

gem 'pg', '~> 1.5'

gem "good_job", "~> 3.21"