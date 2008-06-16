class Monster
  attr_accessor :name, :x, :y, :inventory, :monster_type
  attr_accessor :maxhp, :hp
  attr_accessor :dexterity

  def initialize(attributes)
    @inventory = Inventory.new
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    validate!
  end

  def attack(defender)
    chance = dexterity / (dexterity + defender.dexterity).to_f
    if rand < chance
      "%s hits %s" % [fullname, defender.fullname]
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
end
