# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `Google::Protobuf::FieldOptions::JSType`.
# Please instead update this file by running `bin/tapioca dsl Google::Protobuf::FieldOptions::JSType`.

module Google::Protobuf::FieldOptions::JSType
  class << self
    sig { returns(Google::Protobuf::EnumDescriptor) }
    def descriptor; end

    sig { params(number: Integer).returns(T.nilable(Symbol)) }
    def lookup(number); end

    sig { params(symbol: Symbol).returns(T.nilable(Integer)) }
    def resolve(symbol); end
  end
end

Google::Protobuf::FieldOptions::JSType::JS_NORMAL = 0
Google::Protobuf::FieldOptions::JSType::JS_NUMBER = 2
Google::Protobuf::FieldOptions::JSType::JS_STRING = 1