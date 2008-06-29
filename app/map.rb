class Map
  attr_reader :tiles
  attr_accessor :name, :width, :height, :squares, :game, :monsters, :generate_monster_counter, :lighting, :memory

  def self.load(filename)
    map = self.new
    map.load(filename)
    map.name = File.basename(filename, '.yaml')
    map.memory = (1..map.height).collect{' ' * map.width}
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
    return [:black, ' '[0]] if x >= @width || y >= @height
    if visible_at?(x, y)
      if monster = find_monster(x, y)
        return :white, monster.klass.symbol[0]
      end
      if square = find_square(x, y)
        if !square.items.empty?
          return :white, ItemClass.all[square.items.first.name].symbol[0]
        elsif square.stair
          return :white, (square.stair['down'] ? '>' : '<')[0]
        end
      end
      [:yellow, tiles[y][x]]
    else
      [:white, memory[y][x]]
    end
  #rescue
    #raise $!.class.new($!.to_s + " and x = #{x}, y = #{y} monster is #{monster.monster_type}")
  end

  def opaque_at?(x, y)
    tiles[y][x] == '#'[0]
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
    end
  end

  def find_random_passable_square
    square = [0, 0]
    square = [rand(width), rand(height)] until passable_at?(square.first, square.last)
    square
  end

  def calculate_fov
    @lighting = []
    fov = RubyFov.calculate(self, game.player.x, game.player.y, game.player.perception)

  end

  def visible_at?(x, y)
    @lighting[y * width + x]
  end

  def apply_lighting(x, y)
    @lighting[y * width + x] = true
    @memory[y][x] = square_symbol_at(x, y).last
  end
end
