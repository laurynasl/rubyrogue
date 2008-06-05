class Item
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_s
    @name
  end
end
