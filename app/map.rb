class Map
  attr_reader :tiles
  attr_accessor :name, :width, :height, :squares, :game, :monsters

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
    @monsters = (data['monsters'] || []).collect{|monster| Monster.new monster}
  end

  def find_square(x, y)
    @squares[y * width + x]
  end

  def find_monster(x, y)
    monsters.find{|m| m.x == x && m.y == y}
  end

  def square_symbol_at(x, y)
    return ' '[0] if x >= @width || y >= @height
    if monster = find_monster(x, y)
      return 'k'[0]
    end
    if square = find_square(x, y)
      if !square.items.empty?
        game.item_classes[square.items.first.name].symbol[0]
      elsif square.stair
        return (square.stair['down'] ? '>' : '<')[0]
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
