require 'yaml'

class Game
  attr_reader :map, :item_classes
  attr_accessor :player, :ui, :filename

  def initialize(filename = nil)
    @messages = []
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
    @map = Map.load(File.dirname(filename) + '/' + name + '.yaml')
    @map.game = self
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
    if @map.tiles[y][x] == '.'[0]
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

  def go_downstairs
    if (square = player_square) && (stair = square.stair) && (stair['down'])
      load_map stair['map']
      player.x = stair['x']
      player.y = stair['y']
      output 'You go downstairs'
      ui.redraw_map
      ui.move_player
    else
      output 'You see no downstair here'
    end
  end
end
