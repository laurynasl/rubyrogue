class Monster
  attr_accessor :name, :x, :y, :inventory, :monster_type, :skills
  attr_accessor :maxhp, :hp, :energy, :hpfrac
  attr_accessor :dexterity, :perception, :health
  attr_accessor :weapon

  def initialize(attributes)
    @inventory = Inventory.new
    @energy = 0
    @hpfrac = 0
    @skills = {}
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
        item_class = ItemClass.all[weapon.name]
        damage = inflict_damage(defender, item_class.damage)
        train(item_class.skills, chance, damage)
      else
        damage = inflict_damage(defender, 2)
        train(['unarmed'], chance, damage)
      end
      (defender.alive? ? "%s hits %s" : "%s kills %s") % [fullname, defender.fullname]
    else
      "%s misses %s" % [fullname, defender.fullname]
    end
  end

  def train(skills, chance, amount)
    skills.each do |skill|
      @skills[skill] ||= 0.0
      @skills[skill] += amount / chance / chance / 1000
    end
  end

  # returns amount of damage inflicted
  def inflict_damage(defender, maxdamage)
    damage = rand(maxdamage) + 1
    defender.hp -= damage
    damage
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

  def equip(slot, id)
    @inventory << @weapon if @weapon
    @weapon = inventory.items.delete_at(id)
  end
end
