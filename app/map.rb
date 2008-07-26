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
    @lighting = Lighting.new(:map => self, :memorize => true)
    @lighting.calculate_fov
  end

  def visible_at?(x, y)
    @lighting[y * width + x]
  end

  def apply_lighting(x, y)
    #@lighting[y * width + x] = true
    @memory[y][x] = square_symbol_at(x, y).last
  end

  def find_nearest_visible_monster
  end

  def drop_items(x, y, items)
    square = find_square(x, y, :force => true)
    items.each do |item|
      square.items << item if item
    end
  end

  def inspect
    "<Map #{@name}>"
  end
end
