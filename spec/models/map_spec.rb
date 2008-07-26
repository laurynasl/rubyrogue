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

require File.dirname(__FILE__) + '/../spec_helper'

describe Map, 'load' do
  it "should load map from file" do
    @map = Map.load(TESTMAP)
    @map.name.should == 'cave-1'
    @map.tiles.size.should == 21
    @map.tiles[1].should == "#...........................############\n"
    @map.memory.size.should == 21
    @map.memory[1].should == "                                        "

    @map.width.should == 40
    @map.height.should == 21
    @map.squares.should_not be_nil
    @map.monsters.first.should be_instance_of(Monster)
  end
end

describe Map, 'find_square' do
  it "should find square" do
    @map = Map.load(TESTMAP)
    square = @map.find_square(1, 1)
    square.should be_instance_of(Square)
    square.x.should == 1
    square.y.should == 1
    square.items.first.name.should == 'short sword'
  end

  it "should return nil when square is empty and remove that square" do
    @map = Map.load(TESTMAP)
    square = @map.find_square(1, 1)
    square.items.clear
    square.should be_empty
    @map.find_square(1, 1).should be_nil
    @map.squares[@map.width + 1].should be_nil
  end

  it "should create square if forced" do
    @map = Map.load(TESTMAP)
    @map.find_square(2, 1).should be_nil #ensures changes to map don't silently break test
    square = @map.find_square(2, 1, :force => true)
    square.should be_instance_of(Square)
    square.x.should == 2
    square.y.should == 1
    square.items.should == []
  end
end

describe Map, 'find_monster' do
  it "should find monster" do
    @map = Map.load(TESTMAP)
    monster = @map.find_monster(11, 1)
    monster.should be_instance_of(Monster)
    monster.x.should == 11
    monster.y.should == 1
    monster.monster_type.should == 'kobold'
  end
end

describe Map, "square_symbol_at" do
  before(:each) do
    @game = testgame
    @map = @game.map

  end

  it "should return background" do
    @map.lighting = [true] * (@map.width * @map.height)

    @map.square_symbol_at(3, 1).should be_char(:yellow, '.')
    @map.square_symbol_at(3, 2).should be_char(:yellow, '#')
    #@map.square_symbol_at(2, 1).should be_char('@')
    @map.square_symbol_at(2, 14).should be_char(:white, '(')
    @map.square_symbol_at(10, 1).should be_char(:white, '[')

    @map.find_square(10, 1).items = []
    @map.square_symbol_at(10, 1).should be_char(:yellow, '.')

    @map.square_symbol_at(26, 2).should be_char(:white, '>')
    @map.find_square(26, 2).stair['down'] = false
    @map.square_symbol_at(26, 2).should be_char(:white, '<')
  end

  it "should return space when square is outside of map" do
    @map.lighting = [true] * (@map.width * @map.height)

    @map.square_symbol_at(100, 1).should be_char(:black, ' ')
    @map.square_symbol_at(1, 100).should be_char(:black, ' ')
  end

  it "should display monster" do
    @map.lighting = [true] * (@map.width * @map.height)

    @map.square_symbol_at(11, 1).should be_char(:white, 'k')
    MonsterClass.all['kobold'].symbol = 'K'
    @map.square_symbol_at(11, 1).should be_char(:white, 'K')
  end

  it "should recall from memory" do
    @map.lighting = []
    @map.memory = ['', 'abcdefghijkl']

    @map.square_symbol_at(11, 1).should be_char(:white, 'l')
  end
end

describe Map, "passable_at?" do
  it "should return true when square is passable" do
    @game = testgame
    @map = @game.map

    @map.passable_at?(0, 0).should be_false # #
    @map.passable_at?(1, 1).should be_true  # .
    @map.passable_at?(11, 1).should be_false# k
  end
end

describe Map, "opaque_at?" do
  it "should return true when square opaque (light cannot pass through it)" do
    @game = testgame
    @map = @game.map

    @map.opaque_at?(0, 0).should be_true # #
    @map.opaque_at?(1, 1).should be_false  # .
  end
end

describe Map, "try_to_generate_monster" do
  [nil, 0].each do |value|
    it "should generate monster and set counter to monsters count + 1, multiplied by 100" do
      kobold
      @game = testgame
      @map = @game.map

      @map.generate_monster_counter = value
      @map.should_receive(:find_random_passable_square).and_return([1, 6])
      @kobold.x = nil
      @kobold.y = nil
      MonsterClass.should_receive(:generate).and_return(@kobold)

      @map.try_to_generate_monster

      @map.find_monster(1, 6).should == @kobold
      @map.generate_monster_counter.should == 200
    end
  end

  it "should set count to 300 when there are 2 monsters" do
    kobold
    @game = testgame
    @map = @game.map
    @ui.stub!(:repaint_square)

    @map.monsters << @kobold
    @map.try_to_generate_monster

    @map.generate_monster_counter.should == 300
  end

  it "should not generate monster when counter is more than" do
    @game = testgame
    @map = @game.map

    @map.generate_monster_counter = 11
    @map.should_not_receive(:find_random_passable_square)

    @map.try_to_generate_monster
    @map.generate_monster_counter.should == 10
  end
end

describe Map, "find_random_passable_square" do
  before(:each) do
    @game = testgame
    @map = @game.map
  end

  it "should find at first try" do
    @map.should_receive(:rand).with(40).and_return(1)
    @map.should_receive(:rand).with(21).and_return(6)

    @map.find_random_passable_square.should == [1, 6]
  end

  it "should find at third try" do
    @map.should_receive(:rand).and_return(34, 11, 22, 7, 23, 8)

    @map.find_random_passable_square.should == [23, 8]
  end
end

describe Map, "Field of view (fov)" do
  it "should not see monster which it cannot see" do
    @game = testgame
    @game.player.x = 3
    @game.player.y = 14
    @map = @game.map
    @map.calculate_fov
    @map.visible_at?(4, 14).should be_true
    @map.visible_at?(3, 18).should be_nil
  end
end

describe Map, "apply_lighting" do
  it "should memorize square" do
    @game = testgame
    @map = @game.map

    @map.lighting = Hash.new(true)
    @map.memory[3][2].should == ' '[0]

    @map.apply_lighting(2, 3)

    @map.memory[3][2].should == '#'[0]
  end
end

describe Map, "find_nearest_visible_monster" do
  it "should return when no monster is visible" do
    @game = testgame
    @game.map.find_nearest_visible_monster.should be_nil
  end
end

describe Map, "drop_items" do
  it "should put items at specified coordinates" do
    @game = testgame
    @game.map.drop_items(1, 2, [Item.new('knife'), Item.new('short bow')])
    @game.map.find_square(1, 2).items.collect{|item| item.to_s}.should == ['15 darts', 'knife', 'short bow']
  end
end

describe Map, "inspect" do
  it "should should not be so verbose and display just map name" do
    @game = testgame
    @game.map.inspect.should == '<Map cave-1>'
  end
end
