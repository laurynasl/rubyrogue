class Monster
  attr_accessor :name, :x, :y, :inventory, :monster_type
  attr_accessor :maxhp, :hp, :energy
  attr_accessor :dexterity, :perception, :health

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
    ['hp', 'maxhp', 'dexterity', 'perception', 'health'].each do |attribute|
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
    dx = x - (monster.is_a?(Monster) ? monster.x : monster.first)
    dy = y - (monster.is_a?(Monster) ? monster.y : monster.last)
    dx * dx + dy * dy
  end
end
