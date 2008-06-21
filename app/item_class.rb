class ItemClass
  attr_accessor :damage, :accuracy, :symbol, :skills, :armor, :evasion

  def initialize(name, attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def self.all
    @@all
  end

  def self.all=(value)
    @@all = value
  end

  def self.load_all
    f = File.open('data/items.yaml')
    items_data = YAML::load(f)
    @@all = {}
    items_data.each do |key, value|
      @@all[key] = ItemClass.new(key, value)
    end
    f.close
  end
end
