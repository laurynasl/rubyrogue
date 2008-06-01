class ItemClass
  attr_accessor :damage, :accuracy, :symbol, :skills, :armor, :evasion

  def initialize(name, attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end
end
