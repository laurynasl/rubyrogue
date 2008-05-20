require 'yaml'

class Game
  attr_reader :map
  attr_accessor :player, :ui

  def initialize(filename = nil)
    @messages = []
    #load_datafiles
    if filename
      f = File.open(filename)
      @data = YAML::load(f)
      f.close
      @map = Map.load('maps/' + @data['maps'].first + '.yaml')
      @player = Player.new(@data['player'])
    end
  end

  #def load_datafiles
    #f = File.open('data/items.yaml')
    #@items = YAML::load(f)
    #@messages << @items.to_yaml
    #@messages << 'va'
    #@messages << $*.join(',')
    #f.close
  #end

  def read_message
    @messages.delete_at 0
  end

  def output(data)
    @messages << data
  end

  def move_by(dx, dy)
    player.x += dx
    player.y += dy

    ui.move_player
  end
end
