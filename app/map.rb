class Map
  attr_reader :data, :tiles
  attr_accessor :name, :width, :height

  def initialize
  end

  def self.load(filename)
    map = self.new
    map.load(filename)
    map.name = File.basename(filename, '.yaml')
    map
  end

  def load(filename)
    f = File.open(filename)
    @data = YAML::load(f)
    f.close

    f = File.open(@data["tiles"])
    @tiles = f.readlines
    f.close
    @width = @data['width']
    @height = @data['height']
  end

  def find_square(x, y)
    data['squares'].find do |square|
      square['x'] == x && square['y'] == y
    end
  end
end
