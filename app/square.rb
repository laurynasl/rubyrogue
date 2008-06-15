class Square
  attr_accessor :x, :y, :items, :stair

  def initialize(attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    @items ||= []
  end

  def items=(data)
    @items = data.collect do |item_name|
      Item.new item_name
    end
  end

  def item_names
    items.collect{|item| item.name}
  end

  def look
    if stair
      "you see here: " + {true => "downstairs", false => "upstairs"}[stair['down']]
    else
      "you see here: " + items.join(', ')
    end
  end
end