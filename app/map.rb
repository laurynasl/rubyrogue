class Map
  attr_reader :tiles
  attr_accessor :name, :width, :height, :squares, :game

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
    data = YAML::load(f)
    f.close

    f = File.open(filename.gsub(/\.yaml$/, '.tile'))
    @tiles = f.readlines
    f.close
    @width = data['width']
    @height = data['height']
    @squares = []
    for value in data['squares']
      square = Square.new(value)
      @squares[square.y * width + square.x] = square
    end
  end

  def find_square(x, y)
    @squares[y * width + x]
  end

  def square_symbol_at(x, y)
    return ' '[0] if x >= @width || y >= @height
    if square = find_square(x, y)
      if !square.items.empty?
        game.item_classes[square.items.first.name].symbol[0]
      elsif square.stair
        if square.stair['down']
          '>'[0]
        else
          '<'[0]
        end
      else
        tiles[y][x]
      end
    else
      tiles[y][x]
    end
  rescue
    raise $!.class.new($!.to_s + " and x = #{x}, y = #{y}")
  end
end
