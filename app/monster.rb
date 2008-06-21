class Monster
  attr_accessor :name, :x, :y, :inventory, :monster_type
  attr_accessor :maxhp, :hp, :energy, :hpfrac
  attr_accessor :dexterity, :perception, :health
  attr_accessor :weapon

  def initialize(attributes)
    @inventory = Inventory.new
    @energy = 0
    @hpfrac = 0
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    validate!
  end

  def attack(defender)
    wait
    chance = dexterity / (dexterity + defender.dexterity).to_f
    if rand < chance
      if weapon
        inflict_damage(defender, ItemClass.all[weapon.name].damage)
      else
        inflict_damage(defender, 2)
      end
      (defender.alive? ? "%s hits %s" : "%s kills %s") % [fullname, defender.fullname]
    else
      "%s misses %s" % [fullname, defender.fullname]
    end
  end

  def inflict_damage(defender, maxdamage)
    defender.hp -= rand(maxdamage) + 1
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

  def regenerate
    return if @hp == @maxhp
    @hpfrac += @health
    if @hpfrac >= 1000
      @hpfrac -= 1000
      @hp += 1
    end
  end
end
