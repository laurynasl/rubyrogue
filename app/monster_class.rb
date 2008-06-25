class MonsterClass < Constructable
  attr_accessor :strength, :dexterity, :intelligence, :health, :perception, :danger

  class << self
    include MassLoadable
  end

  def self.load_all
    load_all_from 'data/monsters.yaml'
  end
end
