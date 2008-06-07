class Inventory
  include Enumerable

  attr_accessor :items

  def initialize
    @items = []
  end

  def each
    for item in @items
      yield item
    end
  end

  def <<(item)
    @items << (item.is_a?(Item) ? item : Item.new(item))
    self
  end

  def include?(item_name)
    for item in @items
      return true if item.name == item_name
    end
    false
  end
end
