# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `opentelemetry-instrumentation-trilogy` gem.
# Please instead update this file by running `bin/tapioca gem opentelemetry-instrumentation-trilogy`.

# OpenTelemetry is an open source observability framework, providing a
# general-purpose API, SDK, and related tools required for the instrumentation
# of cloud-native software, frameworks, and libraries.
#
# The OpenTelemetry module provides global accessors for telemetry objects.
# See the documentation for the `opentelemetry-api` gem for details.
#
# source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation.rb#13
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
# source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation.rb#15
module OpenTelemetry::Instrumentation
  # source://opentelemetry-registry/0.3.0/lib/opentelemetry/instrumentation.rb#21
  def registry; end
end

# Contains the OpenTelemetry instrumentation for the Trilogy gem
#
# source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy.rb#13
module OpenTelemetry::Instrumentation::Trilogy
  extend ::OpenTelemetry::Instrumentation::Trilogy

  # Returns the attributes hash representing the Trilogy context found
  # in the optional context or the current context if none is provided.
  #
  # @param context [optional Context] The context to lookup the current
  #   attributes hash. Defaults to Context.current
  #
  # source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy.rb#25
  def attributes(context = T.unsafe(nil)); end

  # Returns a context containing the merged attributes hash, derived from the
  # optional parent context, or the current context if one was not provided.
  #
  # @param context [optional Context] The context to use as the parent for
  #   the returned context
  #
  # source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy.rb#35
  def context_with_attributes(attributes_hash, parent_context: T.unsafe(nil)); end

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
  # source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy.rb#49
  def with_attributes(attributes_hash); end
end

# source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy.rb#16
OpenTelemetry::Instrumentation::Trilogy::CURRENT_ATTRIBUTES_KEY = T.let(T.unsafe(nil), OpenTelemetry::Context::Key)

# The Instrumentation class contains logic to detect and install the Trilogy instrumentation
#
# source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy/instrumentation.rb#11
class OpenTelemetry::Instrumentation::Trilogy::Instrumentation < ::OpenTelemetry::Instrumentation::Base
  private

  # source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy/instrumentation.rb#36
  def patch_client; end

  # source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy/instrumentation.rb#32
  def require_dependencies; end
end

# source://opentelemetry-instrumentation-trilogy//lib/opentelemetry/instrumentation/trilogy/version.rb#10
OpenTelemetry::Instrumentation::Trilogy::VERSION = T.let(T.unsafe(nil), String)
