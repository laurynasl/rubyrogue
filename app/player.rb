class Player
  attr_accessor :name, :x, :y, :inventory

  def initialize(data)
    @name = data['name']
    @x = data['x'].to_i
    @y = data['y'].to_i
    @inventory = Inventory.new
  end
end
