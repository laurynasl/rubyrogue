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

describe Player do
  it "should load player" do
    player = Player.new({
      'monster_type' => 'player',
      'name' => 'Kudlius',
      'x' => 2,
      'y' => 1,
      'map' => 'testmap',
      'hp' => 10,
      'maxhp' => 10,
      'health' => 10,
      'dexterity' => 11,
      'perception' => 7
    })
    player.name.should == 'Kudlius'
    player.x.should == 2
    player.y.should == 1
    player.inventory.should be_an_instance_of(Inventory)
  end
end
