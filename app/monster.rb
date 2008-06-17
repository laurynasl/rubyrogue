class Monster
  attr_accessor :name, :x, :y, :inventory, :monster_type
  attr_accessor :maxhp, :hp, :energy
  attr_accessor :dexterity

  def initialize(attributes)
    @inventory = Inventory.new
    @energy = 0
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    validate!
  end

  def attack(defender)
    wait
    chance = dexterity / (dexterity + defender.dexterity).to_f
    if rand < chance
      defender.hp -= rand(2) + 1
      (defender.alive? ? "%s hits %s" : "%s kills %s") % [fullname, defender.fullname]
    else
      "%s misses %s" % [fullname, defender.fullname]
    end
  end

  def fullname
    name || monster_type
  end

  def validate!
    ['hp', 'maxhp', 'dexterity'].each do |attribute|
      raise "#{attribute} is required!" unless send(attribute)
    end
  end

  def alive?
    hp > 0
  end

  def wait
    @energy -= 100
  end

  def square_range_to(monster)
    dx = x - monster.x
    dy = y - monster.y
    dx * dx + dy * dy
  end
end
