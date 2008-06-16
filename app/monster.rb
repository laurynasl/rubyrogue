class Monster
  attr_accessor :name, :x, :y, :inventory, :monster_type
  attr_accessor :maxhp, :hp
  attr_accessor :dexterity

  def initialize(attributes)
    @inventory = Inventory.new
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attack(defender)
    "%s misses %s" % [fullname, defender.fullname]
  end

  def fullname
    name || monster_type
  end
end
