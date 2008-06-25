class ItemClass < Constructable
  attr_accessor :damage, :accuracy, :symbol, :skill, :armor, :evasion, :damage_type

  class << self
    include MassLoadable
  end


  def self.load_all
    load_all_from 'data/items.yaml'
  end
end
