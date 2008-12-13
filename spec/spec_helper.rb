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

require 'rubygems'
require 'spec'
require File.expand_path(File.dirname(__FILE__) + "/../boot")
require 'lib/rspec_matchers'

Spec::Runner.configure do |config|
end

def testgame
  ItemClass.load_all
  MonsterClass.load_all
  game = Game.new('games/test/game.yaml')
  @ui = mock('ui')
  game.ui = @ui
  game
end

def infinite_game
  ItemClass.load_all
  MonsterClass.load_all
  game = Game.new('games/infinite/game.yaml')
  @ui = mock('ui')
  game.ui = @ui
  game
end

TESTGAME = 'games/test/game.yaml'
TESTMAP = 'games/test/cave-1.yaml'

def it_should_have_fields(object_name, *attributes)
  attributes.each do |attribute|
    it "should have #{attribute}" do
      object = instance_variable_get("@#{object_name}")
      object.send("#{attribute}=", nil)
      lambda {
        object.validate!
      }.should raise_error(RuntimeError, "#{attribute} is required!")
    end
  end
end

def orc(options = {})
  @orc = Monster.new({
    'hp' => 9,
    'maxhp' => 9,
    'health' => 9,
    'dexterity' => 9,
    'perception' => 5,
    'monster_type' => 'orc'
  }.merge(options))
end

def kobold(options = {})
  @kobold = Monster.new({
    'x' => 10,
    'y' => 1,
    'hp' => 4,
    'maxhp' => 4,
    'health' => 4,
    'dexterity' => 7,
    'perception' => 7,
    'monster_type' => 'kobold'
  }.merge(options))
end

def player(options = {})
  @player = Player.new({
    'x' => 3,
    'y' => 1,
    'hp' => 11,
    'maxhp' => 11,
    'health' => 10,
    'dexterity' => 11,
    'perception' => 7,
    'monster_type' => 'player'
  }.merge(options))
end

def stubbed_ui
  @ui = CursesUI.new(TESTGAME)
  @map_win = mock('map_win')
  @map_win.stub!(:setpos)
  @map_win.stub!(:refresh)
  @ui.instance_variable_set(:@map_win, @map_win)
  @game = @ui.game
end
