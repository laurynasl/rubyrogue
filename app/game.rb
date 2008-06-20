require 'yaml'

class Game
  attr_reader :map, :item_classes
  attr_accessor :player, :ui, :filename, :maps

  def initialize(filename = nil)
    @messages = []
    @maps = {}
    load_datafiles
    if filename
      @filename = filename
      f = File.open(filename)
      @data = YAML::load(f)
      f.close
      load_map @data['maps'].first
      @player = Player.new(@data['player'])
    end
  end

  def load_datafiles
    f = File.open('data/items.yaml')
    items_data = YAML::load(f)
    @item_classes = {}
    items_data.each do |key, value|
      @item_classes[key] = ItemClass.new(key, value)
    end
    f.close
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

  def move_by(dx, dy)
    x = player.x + dx
    y = player.y + dy
    if monster = map.find_monster(x, y)
      output player.attack(monster)
      unless monster.alive?
        map.monsters.delete(monster) 
        ui.repaint_square(x, y)
      end
    elsif map.passable_at?(x, y)
      player.wait
      ui.hide_player
      player.x = x
      player.y = y
      ui.move_player
    else
      output "Ouch. You bump into a wall."
    end
  end

  def pickup
    if square = map.find_square(player.x, player.y)
      output 'You pick up ' + square.items.collect{|item| item.name}.join(', ')
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

  def go_stairs(down)
    if (square = player_square) && (stair = square.stair) && (stair['down'] == down)
      load_map stair['map']
      player.x = stair['x']
      player.y = stair['y']
      output "You go #{down ? 'down' : 'up'}stairs"
      ui.redraw_map
      ui.move_player
    else
      output "You see no #{down ? 'down' : 'up'}stairs here"
    end
  end

  def iterate
    while player.energy < 0
      player.energy += player.dexterity
      player.regenerate
      map.monsters.each do |monster|
        monster.regenerate
        monster.energy += monster.dexterity
        move_monster(monster) if monster.energy >= 0
      end
    end
  end

  def move_monster(monster)
    if monster.square_range_to(player) == 1
      output monster.attack(player)
    elsif monster.perception * monster.perception >= (range = monster.square_range_to(player))
      old = [monster.x, monster.y]
      
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

        ui.repaint_square(*old)
        ui.repaint_square(monster.x, monster.y)
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
    File.open(filename, 'r'){|f| YAML.load(f)}
  end
end
