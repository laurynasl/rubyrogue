require 'yaml'

class Game
  attr_reader :map

  def initialize
    @messages = []
    load_datafiles
    load_map
  end

  def load_datafiles
    f = File.open('data/items.yaml')
    @items = YAML::load(f)
    @messages << @items.to_yaml
    @messages << 'va'
    @messages << $*.join(',')
    f.close
  end

  def load_map
    if $*.first
      @map = Map.load($*.first)
    end
  end

  def read_message
    @messages.delete_at 0
  end

  def output(data)
    @messages << data
  end
end
