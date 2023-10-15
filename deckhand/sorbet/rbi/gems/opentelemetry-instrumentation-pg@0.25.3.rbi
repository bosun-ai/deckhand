# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `opentelemetry-instrumentation-pg` gem.
# Please instead update this file by running `bin/tapioca gem opentelemetry-instrumentation-pg`.

# OpenTelemetry is an open source observability framework, providing a
# general-purpose API, SDK, and related tools required for the instrumentation
# of cloud-native software, frameworks, and libraries.
#
# The OpenTelemetry module provides global accessors for telemetry objects.
# See the documentation for the `opentelemetry-api` gem for details.
#
# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation.rb#13
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
# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation.rb#18
module OpenTelemetry::Instrumentation
  # source://opentelemetry-registry/0.3.0/lib/opentelemetry/instrumentation.rb#21
  def registry; end
end

# Contains the OpenTelemetry instrumentation for the Pg gem
#
# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg.rb#13
module OpenTelemetry::Instrumentation::PG
  extend ::OpenTelemetry::Instrumentation::PG

  # Returns the attributes hash representing the postgres client context found
  # in the optional context or the current context if none is provided.
  #
  # @param context [optional Context] The context to lookup the current
  #   attributes hash. Defaults to Context.current
  #
  # source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg.rb#25
  def attributes(context = T.unsafe(nil)); end

  # Activates/deactivates the merged attributes hash within the current Context,
  # which makes the "current attributes hash" available implicitly.
  #
  # On exit, the attributes hash that was active before calling this method
  # will be reactivated.
  #
  # @param span [Span] the span to activate
  # @yield [Hash, Context] yields attributes hash and a context containing the
  #   attributes hash to the block.
  #
  # source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg.rb#39
  def with_attributes(attributes_hash); end
end

# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg.rb#16
OpenTelemetry::Instrumentation::PG::CURRENT_ATTRIBUTES_KEY = T.let(T.unsafe(nil), OpenTelemetry::Context::Key)

# The Instrumentation class contains logic to detect and install the Pg instrumentation
#
# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg/instrumentation.rb#11
class OpenTelemetry::Instrumentation::PG::Instrumentation < ::OpenTelemetry::Instrumentation::Base
  private

  # source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg/instrumentation.rb#33
  def gem_version; end

  # source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg/instrumentation.rb#41
  def patch_client; end

  # source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg/instrumentation.rb#37
  def require_dependencies; end
end

# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg/instrumentation.rb#12
OpenTelemetry::Instrumentation::PG::Instrumentation::MINIMUM_VERSION = T.let(T.unsafe(nil), Gem::Version)

# source://opentelemetry-instrumentation-pg//lib/opentelemetry/instrumentation/pg/version.rb#10
OpenTelemetry::Instrumentation::PG::VERSION = T.let(T.unsafe(nil), String)
