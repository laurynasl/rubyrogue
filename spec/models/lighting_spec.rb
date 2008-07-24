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

describe Lighting do
  it "should initialize tiles to []" do
    @lighting = Lighting.new({})
    @lighting.tiles.should == []
  end
end

describe Lighting, "Field of view (fov)" do
  it "should not see monster which it cannot see" do
    @game = testgame
    @game.player.x = 3
    @game.player.y = 14
    @map = @game.map
    @lighting = Lighting.new(:map => @map)
    @map.lighting = @lighting
    @lighting.calculate_fov
    @map.visible_at?(4, 14).should be_true
    @map.visible_at?(3, 18).should be_nil
  end
end

describe Lighting, "apply_lighting" do
  it "should set value at @lighting to true, but do not change memory" do
    @game = testgame
    @map = @game.map
    @lighting = Lighting.new(:map => @map)
    @map.lighting = @lighting

    @lighting.tiles[3 * @map.width + 2].should be_nil
    @map.memory[3][2].should == ' '[0]

    @lighting.apply_lighting(2, 3)

    @map.memory[3][2].should == ' '[0]
    @map.lighting[3 * @map.width + 2].should be_true
  end

  it "should set value at @lighting array to true and memorize square" do
    @game = testgame
    @map = @game.map
    @lighting = Lighting.new(:map => @map, :memorize => true)
    @map.lighting = @lighting

    @lighting.tiles[3 * @map.width + 2].should be_nil
    @map.memory[3][2].should == ' '[0]

    @lighting.apply_lighting(2, 3)

    @map.memory[3][2].should == '#'[0]
    @map.lighting[3 * @map.width + 2].should be_true
  end
end

describe Lighting, "[]" do
  it "should call tiles method" do
    @lighting = Lighting.new({})
    @lighting.tiles = []
    @lighting[1].should be_nil
    @lighting.tiles[1] = true
    @lighting[1].should be_true
  end
end

describe Lighting, "opaque_at?" do
  it "should return true when square opaque (light cannot pass through it)" do
    @game = testgame
    @map = @game.map
    @lighting = Lighting.new(:map => @map)

    @lighting.opaque_at?(0, 0).should be_true # #
    @lighting.opaque_at?(1, 1).should be_false  # .
  end
end
