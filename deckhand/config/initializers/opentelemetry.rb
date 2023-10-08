require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'deckhand'
  c.use_all # enables all instrumentation!
end

DeckhandTracer = OpenTelemetry.tracer_provider.tracer('deckhand')
