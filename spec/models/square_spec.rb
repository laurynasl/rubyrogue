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

def square_with_items
  Square.new(
    'x' => 3,
    'y' => 17,
    'inventory' => ['short sword', 'leather armor']
  )
end

def square_with_stairs_down
  Square.new(
    'x' => 3,
    'y' => 17,
    'stair' => {
      'map' => 'cave-2',
      'x' => 3,
      'y' => 2,
      'down' => true
    }
  )
end

def square_with_stairs_up
  Square.new(
    'x' => 3,
    'y' => 17,
    'stair' => {
      'map' => 'cave-2',
      'x' => 3,
      'y' => 2,
      'down' => false
    }
  )
end

describe Square do
  it "should initialize with x, y, and items" do
    @square = square_with_items
    @square.x.should == 3
    @square.y.should == 17
    @square.inventory.items[0].name.should == 'short sword'
    @square.inventory.items[1].name.should == 'leather armor'
    @square.item_names.should == ['short sword', 'leather armor']
  end

  it "should have attribute 'stair'" do
    @square = Square.new(
      'x' => 1,
      'y' => 2,
      'stair' => {
        'map' => 'cave-2',
        'x' => 5,
        'y' => 7,
        'down' => true
      }
    )
    @square.inventory.class.should == Inventory
  end
end

describe Square, "look" do
  it "should show items list" do
    @square = square_with_items
    @square.look.should == "you see here: short sword, leather armor"
  end

  it "should show downstairs" do
    @square = square_with_stairs_down
    @square.look.should == "you see here: downstairs"
  end

  it "should show upstairs" do
    @square = square_with_stairs_up
    @square.look.should == "you see here: upstairs"
  end
end

describe Square, "empty?" do
  it "should be empty when without stair and items" do
    square = Square.new({})
    square.should be_empty
  end

  it "should not be empty when has items" do
    square = Square.new(:inventory => ['short sword', 'long sword'])
    square.should_not be_empty
  end

  it "should not be empty when has stair" do
    square = square_with_stairs_down
    square.should_not be_empty
  end
end
