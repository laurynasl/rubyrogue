class MonsterClass < Constructable
  attr_accessor :strength, :dexterity, :intelligence, :health, :perception, :danger

  class << self
    include MassLoadable
  end

  def self.load_all
    load_all_from 'data/monsters.yaml'
  end

  def self.generate
    candidates = all.keys
    name = candidates[rand(candidates.size)]
    prototype = all[name]
    monster = Monster.new({
      :name => name,
      :hp => prototype.health,
      :maxhp => prototype.health,
      :dexterity => prototype.dexterity,
      :perception => prototype.perception,
      :health => prototype.health
    })
  end
end
