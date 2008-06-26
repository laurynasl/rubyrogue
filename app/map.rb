class Map
  attr_reader :tiles
  attr_accessor :name, :width, :height, :squares, :game, :monsters, :generate_monster_counter

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
      return monster.klass.symbol[0]
    end
    if square = find_square(x, y)
      if !square.items.empty?
        ItemClass.all[square.items.first.name].symbol[0]
      elsif square.stair
        return (square.stair['down'] ? '>' : '<')[0]
      else
        tiles[y][x]
      end
    else
      tiles[y][x]
    end
  rescue
    raise $!.class.new($!.to_s + " and x = #{x}, y = #{y} monster is #{monster.monster_type}")
  end

  def passable_at?(x, y)
    tiles[y][x] == '.'[0] && !find_monster(x, y)
  end

  def try_to_generate_monster
    if @generate_monster_counter.to_i != 0
      @generate_monster_counter -= 1
    else
      @generate_monster_counter = (monsters.size + 1) * 100
      monster = MonsterClass.generate
      monster.x, monster.y = find_random_passable_square
      monsters << monster
      game.ui.repaint_square(monster.x, monster.y)
    end
  end

  def find_random_passable_square
    square = [0, 0]
    square = [rand(width), rand(height)] until passable_at?(square.first, square.last)
    square
  end
end
