class ItemClass < Constructable
  attr_accessor :damage, :accuracy, :symbol, :skill, :armor, :evasion, :damage_type
  attr_accessor :ammunition_type, :ranged_damage, :ammunition, :launcher_damage

  class << self
    include MassLoadable
  end


  def self.load_all
    load_all_from 'data/items.yaml'
  end
end
