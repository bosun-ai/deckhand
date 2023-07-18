class ApplicationModel
  include ActiveModel::Model

  def self.attribute(*names)
    @attributes ||= []
    @attributes += names
    attr_accessor(*names)
  end

  def self.attributes
    @attributes || []
  end

  def attributes
    self.class.attributes.each_with_object({}) do |attribute, hash|
      hash[attribute] = send(attribute)
    end
  end

  def as_json(options = {})
    attributes
  end

  def ==(other)
    self.class == other.class && attributes == other.attributes
  end
end
