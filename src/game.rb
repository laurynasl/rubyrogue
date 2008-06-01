require 'yaml'

class Game
  attr_reader :map, :item_classes
  attr_accessor :player, :ui

  def initialize(filename = nil)
    @messages = []
    load_datafiles
    if filename
      f = File.open(filename)
      @data = YAML::load(f)
      f.close
      @map = Map.load('maps/' + @data['maps'].first + '.yaml')
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
end
