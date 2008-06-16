class Monster
  attr_accessor :name, :x, :y, :inventory, :maxhp, :hp, :monster_type

  def initialize(attributes)
    @inventory = Inventory.new
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end
end
