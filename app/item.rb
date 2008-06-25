class Item
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_s
    @name
  end

  def klass
    ItemClass.all[name]
  end
end
