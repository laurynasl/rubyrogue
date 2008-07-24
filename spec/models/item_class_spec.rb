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

describe ItemClass do
  it "should create short sword" do
    @item = ItemClass.new({
      'damage' => 5,
      'accuracy' => 0,
      'symbol' => '(',
      'skill' => 'sword',
      'damage_type' => 'slashing'
    })
    @item.damage.should == 5
    @item.accuracy.should == 0
    @item.symbol.should == '('
    @item.skill.should == 'sword'
  end

  it "should create leather armor" do
    @item = ItemClass.new({
      'armor' => 3,
      'evasion' => 1,
      'symbol' => '['
    })
  end
end

describe ItemClass, 'load_all' do

  it "should load all item classes" do
    ItemClass.load_all

    short_sword = ItemClass.all['short sword']
    short_sword.class.should == ItemClass
  end
end
