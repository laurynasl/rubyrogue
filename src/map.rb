class Map
  attr_reader :data, :tiles

  def initialize
  end

  def self.load(filename)
    map = self.new
    map.load(filename)
    map
  end

  def load(filename)
    f = File.open(filename)
    @data = YAML::load(f)
    f.close

    f = File.open(@data["tiles"])
    @tiles = f.readlines
    f.close
  end
end
