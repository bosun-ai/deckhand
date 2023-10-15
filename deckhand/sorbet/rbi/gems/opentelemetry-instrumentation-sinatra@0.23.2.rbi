# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `opentelemetry-instrumentation-sinatra` gem.
# Please instead update this file by running `bin/tapioca gem opentelemetry-instrumentation-sinatra`.

# OpenTelemetry is an open source observability framework, providing a
# general-purpose API, SDK, and related tools required for the instrumentation
# of cloud-native software, frameworks, and libraries.
#
# The OpenTelemetry module provides global accessors for telemetry objects.
# See the documentation for the `opentelemetry-api` gem for details.
#
# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation.rb#13
module OpenTelemetry
  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#36
  def error_handler; end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#27
  def error_handler=(_arg0); end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#44
  def handle_error(exception: T.unsafe(nil), message: T.unsafe(nil)); end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#30
  def logger; end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#27
  def logger=(_arg0); end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#69
  def propagation; end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#27
  def propagation=(_arg0); end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#64
  def tracer_provider; end

  # source://opentelemetry-api/1.2.3/lib/opentelemetry.rb#52
  def tracer_provider=(provider); end
end

# "Instrumentation" are specified by
# https://github.com/open-telemetry/opentelemetry-specification/blob/784635d01d8690c8f5fcd1f55bdbc8a13cf2f4f2/specification/glossary.md#instrumentation-library
#
# Instrumentation should be able to handle the case when the library is not installed on a user's system.
#
# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation.rb#18
module OpenTelemetry::Instrumentation
  # source://opentelemetry-registry/0.3.0/lib/opentelemetry/instrumentation.rb#21
  def registry; end
end

# Contains the OpenTelemetry instrumentation for the Sinatra gem
#
# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra.rb#13
module OpenTelemetry::Instrumentation::Sinatra; end

# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/extensions/tracer_extension.rb#12
module OpenTelemetry::Instrumentation::Sinatra::Extensions; end

# Sinatra extension that installs TracerMiddleware and provides
# tracing for template rendering
#
# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/extensions/tracer_extension.rb#15
module OpenTelemetry::Instrumentation::Sinatra::Extensions::TracerExtension
  class << self
    # Sinatra hook after extension is registered
    #
    # source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/extensions/tracer_extension.rb#17
    def registered(app); end
  end
end

# The Instrumentation class contains logic to detect and install the Sinatra
# instrumentation
#
# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/instrumentation.rb#14
class OpenTelemetry::Instrumentation::Sinatra::Instrumentation < ::OpenTelemetry::Instrumentation::Base; end

# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/middlewares/tracer_middleware.rb#11
module OpenTelemetry::Instrumentation::Sinatra::Middlewares; end

# Middleware to trace Sinatra requests
#
# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/middlewares/tracer_middleware.rb#13
class OpenTelemetry::Instrumentation::Sinatra::Middlewares::TracerMiddleware
  # @return [TracerMiddleware] a new instance of TracerMiddleware
  #
  # source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/middlewares/tracer_middleware.rb#14
  def initialize(app); end

  # source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/middlewares/tracer_middleware.rb#18
  def call(env); end

  # source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/middlewares/tracer_middleware.rb#24
  def trace_response(env, response); end
end

# source://opentelemetry-instrumentation-sinatra//lib/opentelemetry/instrumentation/sinatra/version.rb#10
OpenTelemetry::Instrumentation::Sinatra::VERSION = T.let(T.unsafe(nil), String)
