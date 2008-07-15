require 'yaml'

class Game
  attr_reader :map
  attr_accessor :player, :ui, :filename, :maps

  def initialize(filename = nil)
    @messages = []
    @maps = {}
    if filename
      ItemClass.load_all
      MonsterClass.load_all
      @filename = filename
      f = File.open(filename)
      @data = YAML::load(f)
      f.close
      load_map @data['maps'].first
      @player = Player.new(@data['player'])
    end
  end

  def load_map(name)
    unless @map = @maps[name]
      @map = Map.load(File.dirname(filename) + '/' + name + '.yaml')
      @maps[name] = @map
      @map.game = self
    end
  end

  def read_message
    @messages.delete_at 0
  end

  def output(data)
    @messages << data
  end

  # player moves. if moves into wall, stops. if moves into monster, attacks
  def move_by(dx, dy)
    x = player.x + dx
    y = player.y + dy
    if monster = map.find_monster(x, y)
      output player.attack(monster)
      unless monster.alive?
        map.monsters.delete(monster) 
      end
    elsif map.passable_at?(x, y)
      player.wait
      player.x = x
      player.y = y
    else
      output "Ouch. You bump into a wall."
    end
  end

  # player picks up all items from square he is standing at
  def pickup
    if square = player_square
      output 'You pick up ' + square.items.collect{|item| item.to_s}.join(', ')
      for item in square.items
        player.inventory << item
      end
      square.items.clear
    else
      output 'There is nothing to pick up'
    end
  end

  def player_square
    map.find_square player.x, player.y
  end

  # go stairs. down: true - down, false - up
  def go_stairs(down)
    if (square = player_square) && (stair = square.stair) && (stair['down'] == down)
      load_map stair['map']
      player.x = stair['x']
      player.y = stair['y']
      output "You go #{down ? 'down' : 'up'}stairs"
    else
      output "You see no #{down ? 'down' : 'up'}stairs here"
    end
  end

  # single game cycle
  def iterate
    while player.energy < 0
      player.energy += player.dexterity
      player.regenerate
      map.monsters.each do |monster|
        monster.regenerate
        monster.energy += monster.dexterity
        move_monster(monster) if monster.energy >= 0
      end
      map.try_to_generate_monster
    end
  end

  # primitive AI for moving monster
  def move_monster(monster)
    if monster.square_range_to(player) == 1
      output monster.attack(player)
    elsif monster.perception * monster.perception >= (range = monster.square_range_to(player))
      pair = nil
      [[1, 0], [0, 1], [-1, 0], [0, -1]].each do |dx, dy|
        r = player.square_range_to([monster.x + dx, monster.y + dy])
        if r < range && map.passable_at?(monster.x + dx, monster.y + dy)
          range = r
          pair = [dx, dy]
        end
      end

      if pair
        monster.x += pair.first
        monster.y += pair.last
      end
      monster.wait
    else
      monster.wait
    end
  end

  def save(name)
    #Dir.mkdir('games/' + name)
    File.open("savegames/#{name}.yaml", 'w') {|f| f.write self.to_yaml}
  end

  def self.restore(filename)
    ItemClass.load_all
    MonsterClass.load_all
    File.open(filename, 'r'){|f| YAML.load(f)}
  end
end
