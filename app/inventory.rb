class Inventory
  include Enumerable

  def initialize
    @items = []
  end

  def each
    for item in @items
      yield item
    end
  end

  def <<(item)
    @items << Item.new(item)
    self
  end

  def include?(item_name)
    for item in @items
      return true if item.name == item_name
    end
    false
  end
end
