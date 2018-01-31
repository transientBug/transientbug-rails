# This is used with ActiveModels .attribute which allows us to write custom
# serializers and deserializers, in this case, treating a string in the
# database as an Addressable::URI object in ruby land
class AddressableUriType < ActiveRecord::Type::String
  def deserialize value
    # super unless value.is_a? String
    to_addressable value
  end

  def serialize value
    to_addressable(value).to_s
  end

  private

  def to_addressable value
    value ||= ""
    Addressable::URI.parse(value).omit(:fragment)
  end
end
