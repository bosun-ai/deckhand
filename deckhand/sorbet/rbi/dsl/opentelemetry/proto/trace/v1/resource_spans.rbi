# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `Opentelemetry::Proto::Trace::V1::ResourceSpans`.
# Please instead update this file by running `bin/tapioca dsl Opentelemetry::Proto::Trace::V1::ResourceSpans`.

class Opentelemetry::Proto::Trace::V1::ResourceSpans
  sig do
    params(
      resource: T.nilable(Opentelemetry::Proto::Resource::V1::Resource),
      schema_url: T.nilable(String),
      scope_spans: T.nilable(T.any(Google::Protobuf::RepeatedField[Opentelemetry::Proto::Trace::V1::ScopeSpans], T::Array[Opentelemetry::Proto::Trace::V1::ScopeSpans]))
    ).void
  end
  def initialize(resource: nil, schema_url: nil, scope_spans: T.unsafe(nil)); end

  sig { void }
  def clear_resource; end

  sig { void }
  def clear_schema_url; end

  sig { void }
  def clear_scope_spans; end

  sig { returns(T.nilable(Opentelemetry::Proto::Resource::V1::Resource)) }
  def resource; end

  sig { params(value: T.nilable(Opentelemetry::Proto::Resource::V1::Resource)).void }
  def resource=(value); end

  sig { returns(String) }
  def schema_url; end

  sig { params(value: String).void }
  def schema_url=(value); end

  sig { returns(Google::Protobuf::RepeatedField[Opentelemetry::Proto::Trace::V1::ScopeSpans]) }
  def scope_spans; end

  sig { params(value: Google::Protobuf::RepeatedField[Opentelemetry::Proto::Trace::V1::ScopeSpans]).void }
  def scope_spans=(value); end
end