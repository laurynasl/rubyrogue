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

require 'yaml'

class Game
  attr_reader :map
  attr_accessor :player, :ui, :filename, :maps, :dungeons

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
      @player = Player.new(@data['player'])
      if @player.map
        load_map @player.map
      elsif @player.dungeon
        @dungeons = @data['dungeons']
        load_map(@player.dungeon + '-1')
        @player.x, @player.y = *@map.find_random_passable_square
      end
    end
  end

  def load_map(name)
    unless @map = @maps[name]
      static_filename = File.dirname(filename) + '/' + name + '.yaml'
      if File.exists?(static_filename)
        @map = Map.load(static_filename)
      else
        @map = Map.generate(:width => 120, :height => 45, :rooms => 50)
        @map.name = name
      end
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

  def kill_monster(monster)
    map.monsters.delete(monster) 
    map.drop_items(monster.x, monster.y, monster.inventory.items + [monster.weapon, monster.armor, monster.ammunition])
  end

  # player moves. if moves into wall, stops. if moves into monster, attacks
  def move_by(dx, dy)
    x = player.x + dx
    y = player.y + dy
    if monster = map.find_monster(x, y)
      output player.attack(monster)
      unless monster.alive?
        kill_monster(monster) 
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
      output 'You pick up ' + square.inventory.collect{|item| item.to_s}.join(', ')
      for item in square.inventory
        player.inventory << item
      end
      square.inventory.items.clear
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
    File.open("savegames/#{name}.yaml", 'w') {|f| f.write self.to_yaml}
  end

  def self.restore(filename)
    ItemClass.load_all
    MonsterClass.load_all
    File.open(filename, 'r'){|f| YAML.load(f)}
  end

  def ranged_attack(x, y)
    if defender = map.find_monster(x, y)
      text = player.ranged_attack(defender, map)
      kill_monster(defender) unless defender.alive?
      text
    else
      ammo = player.drop_ammo(map, x, y)
      "Your #{ammo.name} hits nobody"
    end
  end
end
