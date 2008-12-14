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

describe MonsterClass do
  it "should be constructable" do
    klass = MonsterClass.new({
      'strength' => 6,
      'dexterity' => 7,
      'perception' => 5,
      'health' => 5,
      'intelligence' => 6,
      'danger' => 1,
      'symbol' => 'k'
    })
    klass.strength.should == 6
  end

  it "should be mass loadable" do
    MonsterClass.load_all
    MonsterClass.all['kobold'].should_not be_nil
  end
end

describe MonsterClass, "self.generate" do
  before(:each) do
    MonsterClass.load_all
    MonsterClass.all.should_receive(:keys).and_return(['elf', 'goblin', 'ogre', 'kobold']) # monster levels: 4, 1, 5, 1
    MonsterClass.should_receive(:generate_inventory)
  end
  
  it "should generate kobold" do
    MonsterClass.should_receive(:rand).with(4).and_return(3)
    monster = MonsterClass.generate(:monster_level => 10)
    monster.monster_type.should == 'kobold'
  end

  it "should try 3 times to generate weakest monster" do
    MonsterClass.should_receive(:rand).with(4).and_return(2, 1, 3)
    monster = MonsterClass.generate(:monster_level => 0)
    monster.monster_type.should == 'goblin'
  end

  it "should try 3 times to generate strongest monster" do
    MonsterClass.should_receive(:rand).with(4).and_return(0, 1, 3)
    monster = MonsterClass.generate(:monster_level => 1000)
    monster.monster_type.should == 'elf'
  end
end

describe MonsterClass, "self.generate_inventory" do
  it "should create dagger for kobold" do
    ItemClass.load_all
    ItemClass.all.should_receive(:keys).and_return(['short sword', 'dagger', 'leather armor', 'dart'])

    kobold
    MonsterClass.should_receive(:rand).with(4).and_return(1)
    MonsterClass.should_receive(:rand).with(100).and_return(39)
    MonsterClass.generate_inventory(kobold)
    @kobold.inventory.should include('dagger')
  end

  it "should generate no item because roll is unsuccessful" do
    ItemClass.load_all
    ItemClass.all.should_receive(:keys).and_return(['short sword', 'dagger', 'leather armor', 'dart'])

    kobold
    MonsterClass.should_receive(:rand).with(4).and_return(1)
    MonsterClass.should_receive(:rand).with(100).and_return(40)
    MonsterClass.generate_inventory(kobold)
    @kobold.inventory.should_not include('dagger')
  end

  it "should generate 13 darts" do
    ItemClass.load_all
    ItemClass.all.should_receive(:keys).and_return(['short sword', 'dagger', 'leather armor', 'dart'])

    kobold
    MonsterClass.should_receive(:rand).with(4).and_return(3)
    MonsterClass.should_receive(:rand).with(100).and_return(39)
    MonsterClass.should_receive(:rand).with(21).and_return(3)
    MonsterClass.generate_inventory(kobold)
    @kobold.inventory.should include('dart')
  end
end
