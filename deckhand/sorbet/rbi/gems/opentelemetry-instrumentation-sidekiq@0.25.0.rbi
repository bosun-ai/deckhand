# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `opentelemetry-instrumentation-sidekiq` gem.
# Please instead update this file by running `bin/tapioca gem opentelemetry-instrumentation-sidekiq`.

# OpenTelemetry is an open source observability framework, providing a
# general-purpose API, SDK, and related tools required for the instrumentation
# of cloud-native software, frameworks, and libraries.
#
# The OpenTelemetry module provides global accessors for telemetry objects.
# See the documentation for the `opentelemetry-api` gem for details.
#
# source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation.rb#13
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
# source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation.rb#18
module OpenTelemetry::Instrumentation
  # source://opentelemetry-registry/0.3.0/lib/opentelemetry/instrumentation.rb#21
  def registry; end
end

# Contains the OpenTelemetry instrumentation for the Sidekiq gem
#
# source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq.rb#13
module OpenTelemetry::Instrumentation::Sidekiq; end

# The Instrumentation class contains logic to detect and install the Sidekiq
# instrumentation
#
# source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#12
class OpenTelemetry::Instrumentation::Sidekiq::Instrumentation < ::OpenTelemetry::Instrumentation::Base
  private

  # source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#67
  def add_client_middleware; end

  # source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#75
  def add_server_middleware; end

  # source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#40
  def gem_version; end

  # source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#53
  def patch_on_startup; end

  # source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#44
  def require_dependencies; end
end

# source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/instrumentation.rb#13
OpenTelemetry::Instrumentation::Sidekiq::Instrumentation::MINIMUM_VERSION = T.let(T.unsafe(nil), Gem::Version)

# source://opentelemetry-instrumentation-sidekiq//lib/opentelemetry/instrumentation/sidekiq/version.rb#10
OpenTelemetry::Instrumentation::Sidekiq::VERSION = T.let(T.unsafe(nil), String)
