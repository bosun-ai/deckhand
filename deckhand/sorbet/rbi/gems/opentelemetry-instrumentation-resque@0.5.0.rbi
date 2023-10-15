# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `opentelemetry-instrumentation-resque` gem.
# Please instead update this file by running `bin/tapioca gem opentelemetry-instrumentation-resque`.

# OpenTelemetry is an open source observability framework, providing a
# general-purpose API, SDK, and related tools required for the instrumentation
# of cloud-native software, frameworks, and libraries.
#
# The OpenTelemetry module provides global accessors for telemetry objects.
# See the documentation for the `opentelemetry-api` gem for details.
#
# source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation.rb#13
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

# Instrumentation should be able to handle the case when the library is not installed on a user's system.
#
# source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation.rb#15
module OpenTelemetry::Instrumentation
  # source://opentelemetry-registry/0.3.0/lib/opentelemetry/instrumentation.rb#21
  def registry; end
end

# Contains the OpenTelemetry instrumentation for the Resque gem
#
# source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation/resque.rb#13
module OpenTelemetry::Instrumentation::Resque; end

# The Instrumentation class contains logic to detect and install the Resque instrumentation
#
# source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation/resque/instrumentation.rb#11
class OpenTelemetry::Instrumentation::Resque::Instrumentation < ::OpenTelemetry::Instrumentation::Base
  private

  # source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation/resque/instrumentation.rb#51
  def patch; end

  # source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation/resque/instrumentation.rb#56
  def require_dependencies; end
end

# source://opentelemetry-instrumentation-resque//lib/opentelemetry/instrumentation/resque/version.rb#10
OpenTelemetry::Instrumentation::Resque::VERSION = T.let(T.unsafe(nil), String)
