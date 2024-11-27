require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  # log opentelemetry setup to a separate log file
  c.logger = ActiveSupport::Logger.new("log/open-telemetry-#{Rails.env}.log")
  c.service_name = 'deckhand'
  c.use_all # enables all instrumentation!
end

DeckhandTracer = OpenTelemetry.tracer_provider.tracer('deckhand')
