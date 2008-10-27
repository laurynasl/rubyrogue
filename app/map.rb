# Copyright (C) 2008 Laurynas Liutkus
# All rights reserved. See the file named LICENSE in the distribution
# for more details.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class Map
  attr_accessor :name, :width, :height, :squares, :game, :monsters, :generate_monster_counter, :tiles
  # lightning
  attr_accessor :lighting, :memory, :spotted_monsters
  # map generation
  attr_accessor :rooms

  def initialize
    @spotted_monsters = []
  end

  def self.load(filename)
    map = self.new
    map.load(filename)
    map.name = File.basename(filename, '.yaml')
    map.memory = (1..map.height).collect{' ' * map.width}
    map
  end

  def load(filename)
    data = File.open(filename){|f| YAML::load(f)}

    @tiles = File.open(filename.gsub(/\.yaml$/, '.tile')){|f| f.readlines.collect{|line| line.gsub("\n", "")}}
    @width = data['width']
    @height = data['height']
    @squares = []
    for value in data['squares']
      square = Square.new(value)
      @squares[square.y * width + square.x] = square
    end
    @monsters = (data['monsters'] || []).collect{|monster| Monster.new monster}
  end

  def find_square(x, y, options = {})
    i = y * width + x
    found = @squares[i]
    if !found && options[:force]
      @squares[i] = Square.new({:x => x, :y => y})
    elsif found && found.empty?
      @squares[i] = nil
    else
      found
    end
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
        if !square.inventory.items.empty?
          return :white, ItemClass.all[square.inventory.items.first.name].symbol[0]
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
    @spotted_monsters = []
    @lighting = Lighting.new(:map => self, :memorize => true)
    @lighting.calculate_fov
  end

  def visible_at?(x, y)
    @lighting[y * width + x]
  end

  def apply_lighting(x, y)
    @memory[y][x] = square_symbol_at(x, y).last
    if monster = find_monster(x, y)
      @spotted_monsters << monster
    end
  end

  def find_nearest_visible_monster
    @spotted_monsters.min{|a, b| game.player.square_range_to(a) <=> game.player.square_range_to(b)}
  end

  def drop_items(x, y, items)
    square = find_square(x, y, :force => true)
    items.each do |item|
      square.inventory << item if item
    end
  end

  def inspect
    "<Map #{@name}>"
  end

  # Map generation methods. hard to test because of current inability to mock <code>rand</code>

  def self.generate(options)
    map = Map.new
    map.width = options[:width]
    map.height = options[:height]
    map.tiles = []
    map.height.times do |i|
      map.tiles << '#' * map.width
    end

    map.rooms = []
    options[:rooms].times do
      room = map.generate_room
      if map.can_place_room?(room)
        map.place_room(room) 
        if map.rooms.size > 0
          #room2 = map.rooms[rand(map.rooms.size)]
          room2 = map.rooms.min do |r1, r2|
            range_between_rooms(room, r1) <=> range_between_rooms(room, r2)
          end
          map.join_rooms(room2, room)
        end
        map.rooms << room
      end
    end

    map
  end

  def self.range_between_rooms(r1, r2)
    x1 = r1[:x] + (r1[:width] - 1) / 2
    x2 = r2[:x] + (r2[:width] - 1) / 2
    y1 = r1[:y] + (r1[:height] - 1) / 2
    y2 = r2[:y] + (r1[:height] - 1) / 2
    (x1 - x2).abs + (y1 - y2).abs
  end

  def generate_room
    room = {}
    room[:width] = rand(5) + 4
    room[:height] = rand(3) + 3
    room[:x] = rand(width - room[:width] - 2) + 1
    room[:y] = rand(height - room[:height] - 2) + 1
    room
  end

  def place_room(room, symbol='.') #untested
    (room[:y]..room[:y]+room[:height]-1).each do |y|
      (room[:x]..room[:x]+room[:width]-1).each do |x|
        tiles[y][x] = symbol
      end
    end
  end

  def can_place_room?(new_room)
    rooms.each do |room|
      next if new_room[:y] + new_room[:height] + 1 < room[:y]
      next if new_room[:y] > room[:y] + room[:height]
      next if new_room[:x] + new_room[:width] + 1 < room[:x]
      next if new_room[:x] > room[:x] + room[:width]
      return false
    end
    true
  end

  def join_rooms(room1, room2)
    x1 = room1[:x] + (room1[:width] - 1) / 2
    x2 = room2[:x] + (room2[:width] - 1) / 2
    y1 = room1[:y] + (room1[:height] - 1) / 2
    y2 = room2[:y] + (room2[:height] - 1) / 2
    ([x1, x2].min..[x1, x2].max).each do |x|
      tiles[y2][x] = '.'
    end
    ([y1, y2].min..[y1, y2].max).each do |y|
      tiles[y][x1] = '.'
    end
    #tiles[y2][x1] = ' '
    #p [x1, y1]
    #p [x2, y2]
  end
end
