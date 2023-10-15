# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `Google::Rpc::Status`.
# Please instead update this file by running `bin/tapioca dsl Google::Rpc::Status`.

class Google::Rpc::Status
  sig do
    params(
      code: T.nilable(Integer),
      details: T.nilable(T.any(Google::Protobuf::RepeatedField[Google::Protobuf::Any], T::Array[Google::Protobuf::Any])),
      message: T.nilable(String)
    ).void
  end
  def initialize(code: nil, details: T.unsafe(nil), message: nil); end

  sig { void }
  def clear_code; end

  sig { void }
  def clear_details; end

  sig { void }
  def clear_message; end

  sig { returns(Integer) }
  def code; end

  sig { params(value: Integer).void }
  def code=(value); end

  sig { returns(Google::Protobuf::RepeatedField[Google::Protobuf::Any]) }
  def details; end

  sig { params(value: Google::Protobuf::RepeatedField[Google::Protobuf::Any]).void }
  def details=(value); end

  sig { returns(String) }
  def message; end

  sig { params(value: String).void }
  def message=(value); end
end
