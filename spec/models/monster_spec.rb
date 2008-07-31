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

describe Monster do
  before(:each) do
    kobold
  end

  it "should load monster" do
    @kobold.x.should == 10
    @kobold.y.should == 1
    @kobold.maxhp.should == 4
    @kobold.hp.should == 4
    @kobold.energy.should == 0
    @kobold.hpfrac.should == 0
    @kobold.inventory.should be_an_instance_of(Inventory)
  end

  it "should fail to create monster without hp" do
    lambda {
      Monster.new 'maxhp' => 5
    }.should raise_error(RuntimeError, 'hp is required!')
  end

  it "should be valid" do
    @kobold.validate!
  end

  it_should_have_fields :kobold, 'monster_type', 'dexterity', 'perception', 'health', 'hp', 'maxhp'
end

describe Monster, "fullname" do
  before(:each) do
    orc
  end

  it "should return monster_type" do
    @orc.fullname.should == 'orc'
  end

  it "should return name when it is present" do
    @orc.name = 'Sigmund'
    @orc.fullname.should == 'Sigmund'
  end
end

describe Monster, "attack" do
  before(:each) do
    orc
    kobold
  end

  it "should attack and miss" do
    @orc.should_receive(:rand).and_return(0.5625)
    @orc.attack(@kobold).should == "orc misses kobold"
    @orc.energy.should == -100
  end

  it "should attack and hit" do
    @orc.should_receive(:rand).and_return(0.5624, 1)
    @orc.attack(@kobold).should == "orc hits kobold"
    @kobold.hp.should == 2
  end

  it "should attack and kill" do
    @kobold.hp = 2
    @orc.should_receive(:rand).and_return(0.5624, 1)
    @orc.attack(@kobold).should == "orc kills kobold"
    @kobold.hp.should == 0
  end

  it "should inflict damage of maximum 2 when without a weapon" do
    @orc.should_receive(:rand).and_return(0.5624)
    @orc.should_receive(:inflict_damage).with(@kobold, 2).and_return(1)
    @orc.should_receive(:train).with('unarmed', 0.5625, 1)
    @orc.attack(@kobold)
  end

  it "should inflict damage of maximum 5 when attacking with short sword" do
    ItemClass.load_all
    @orc.weapon = Item.new('short sword')
    @orc.should_receive(:rand).and_return(0.5624)
    @orc.should_receive(:inflict_damage).with(@kobold, 5).and_return(3)
    @orc.should_receive(:train).with('sword', 0.5625, 3)
    @orc.attack(@kobold)
  end

  it "should attack, hit but inflict no damage" do
    @orc.should_receive(:rand).and_return(0.5624)
    @orc.should_receive(:inflict_damage).with(@kobold, 2).and_return(0)
    @orc.attack(@kobold).should == "orc hits, but does not manage to hurt kobold"
  end
end

describe Monster, "train" do
  it "should train new skill and improve level" do
    orc
    @orc.train('unarmed', 0.25, 2)
    @orc.skills['unarmed'].should == 0.32
    @orc.skills['level'].should == 0.032
  end

  it "should improve existing skills" do
    orc
    @orc.skills['dagger'] = 3.2
    @orc.skills['level'] = 2.2
    @orc.train('dagger', 0.5, 6)
    @orc.skills['dagger'].to_s.should == '3.44'
    @orc.skills['level'].to_s.should == '2.224'
  end
end

describe Monster, "skill" do
  it "should return 0 when skill is not present" do
    orc
    @orc.skill('sword').should == 0
  end

  it "should return 1 when skill is 1" do
    orc
    orc.skills['sword'] = 1
    @orc.skill('sword').should == 1
  end

  it "should return square root of skill experience, rounded down" do
    orc
    orc.skills['sword'] = 15.2363
    @orc.skill('sword').should == 3
  end
end

describe Monster, "melee_chance_to_hit" do
  before(:each) do
    orc
    kobold
  end

  it "should return dexterity divided by sum of both oponents dexterity" do
    @orc.melee_chance_to_hit(@kobold).should == 0.5625
  end

  it "should add triple unarmed skill value for attacker" do
    @orc.skills['unarmed'] = 4 # actual value will be 2
    @orc.skill('unarmed').should == 2
    @kobold.skills['unarmed'] = 1
    @orc.melee_chance_to_hit(@kobold).should == 0.6
  end
end

describe Monster, "melee_attack_rating" do
  before(:each) do
    orc
  end

  it "should return sum of dexterity and triple unarmed skill" do
    @orc.skills['unarmed'] = 4 #2
    @orc.melee_attack_rating.should == 15
  end

  it "should use equipped weapon skill" do
    ItemClass.load_all
    @orc.weapon = Item.new('short sword')
    @orc.skills['sword'] = 1
    @orc.melee_attack_rating.should == 12
  end

  it "should aply weapon modifier" do
    ItemClass.load_all
    @orc.weapon = Item.new('long sword')
    @orc.skills['sword'] = 4
    @orc.melee_attack_rating.should == 12
  end
end

describe Monster, "ranged_attack_rating" do
  before(:each) do
    orc
    ItemClass.load_all
  end

  it "should return sum of perception, triple rock skill and triple accuracy" do
    @orc.ammunition = Item.new('3 rocks')
    @orc.skills['rock'] = 4 #2
    @orc.ranged_attack_rating.should == 8
  end

  it "should work for darts" do
    @orc.ammunition = Item.new('6 darts')
    @orc.skills['dart'] = 9 #3
    @orc.perception = 6
    @orc.ranged_attack_rating.should == 18
  end
end

describe Monster, "inflict_damage" do
  before(:each) do
    orc
    kobold
  end

  it "should inflict damage of maximum 2 when without a weapon" do
    @kobold.hp = 3
    @orc.should_receive(:rand).with(3).and_return(1)
    @orc.inflict_damage(@kobold, 3).should == 2
    @kobold.hp.should == 1
  end

  it "leather armor should reduce damage" do
    @orc.should_receive(:rand).with(4).and_return(3)
    @kobold.should_receive(:rand_armor).and_return(2)
    @orc.inflict_damage(@kobold, 4).should == 2
  end

  it "should return 0 if damage is nonpositive" do
    @orc.should_receive(:rand).with(4).and_return(0)
    @kobold.should_receive(:rand_armor).and_return(3)
    @orc.inflict_damage(@kobold, 4).should == 0
  end

  it "should raise exception when maxdamage is nil" do
    lambda {
      @orc.inflict_damage(@kobold, nil)
    }.should raise_error("maxdamage should not be nil")
  end
end

describe Monster, "rand_armor" do
  it "should return 0 when monster has no armor" do
    kobold
    @kobold.rand_armor.should == 0
  end

  it "should return number between 0 and 3 for leather armor" do
    kobold
    ItemClass.load_all
    @kobold.armor = Item.new('leather armor')
    @kobold.should_receive(:rand).with(4).and_return(2)
    @kobold.rand_armor.should == 2
  end
end

describe Monster, "alive?" do
  it "should be alive when hp is at least 1" do
    orc
    @orc.should be_alive
    @orc.hp = 0
    @orc.should_not be_alive
    @orc.hp = -1
    @orc.should_not be_alive
  end
end

describe Monster, "wait" do
  it "should decrease energy by 100" do
    orc
    @orc.energy.should be_zero
    @orc.wait
    @orc.energy.should == -100

    @orc.energy = 2
    @orc.wait
    @orc.energy.should == -98
  end
end

describe Monster, "square_range_to" do
  before(:each) do
    orc
    kobold
  end

  it "should return sum of squares of diffs" do
    @orc.x = 7
    @orc.y = 13
    @kobold.x = 19
    @kobold.y = 2
    @orc.square_range_to(@kobold).should == 265
  end

  it "should accept array of coordinates instead of monster" do
    @orc.x = 7
    @orc.y = 13
    @orc.square_range_to([19, 2]).should == 265
  end
end

describe Monster, "regenerate" do
  it "should increase hpfrac by health attribute value" do
    orc
    @orc.hp = 7
    @orc.hpfrac = 15
    @orc.regenerate
    @orc.hpfrac.should == 24
  end

  it "should increase health when hpfrac reaches 1000" do
    orc
    @orc.hp = 7
    @orc.hpfrac = 995
    @orc.regenerate
    @orc.hpfrac.should == 4
    @orc.hp.should == 8
  end

  it "should not regenerate when hp is full" do
    orc
    @orc.regenerate
    @orc.hpfrac.should == 0
  end
end

describe Monster, "equip" do
  it "should equip dagger to weapon slot (use filter by slot, so leather armor is skipped)" do
    orc
    @orc.inventory << 'short sword' << 'leather armor' << 'dagger'
    @orc.equip('weapon', 1) #dagger
    @orc.weapon.to_s.should == 'dagger'
    @orc.inventory.items.size.should == 2
  end

  it "should equip leather armor to armor slot" do
    orc
    @orc.inventory << 'leather armor'
    @orc.equip('armor', 0)
    @orc.armor.to_s.should == 'leather armor'
  end

  it "should equip 13 darts to ammunition slot" do
    orc
    @orc.inventory << '13 darts'
    @orc.equip('ammunition', 0)
    @orc.ammunition.to_s.should == '13 darts'
  end
end

describe Monster, "unequip" do
  it "should unequip dagger" do
    orc
    @orc.inventory.should_not include('dagger')
    @orc.weapon = Item.new('dagger')
    @orc.unequip('weapon')
    @orc.inventory.should include('dagger')
    @orc.weapon.should be_nil
  end
end

describe Monster, 'klass' do
  it "should return it's MonsterClass" do
    MonsterClass.load_all
    orc
    @orc.klass.symbol.should == 'o'
  end
end

describe Monster, "ranged_attack" do
  before(:each) do
    orc(:x => 12, :y => 1)
    @orc.ammunition = Item.new('15 darts')
    @orc.skills['dart'] = 4 #2
    kobold(:x => 16, :y => 1)
    @map = mock('map')
  end

  it "should miss" do
    @orc.should_receive(:rand).and_return(0.4376)
    @orc.ranged_attack(@kobold, @map).should == "orc misses kobold"
    @orc.energy.should == -100
  end

  it "should say that attacking non-monster is not allowed" do
    @orc.ranged_attack(nil, @map).should == "you should target monster"
    @orc.energy.should == 0
  end

  it "should hit" do
    # attacker: perception 5 + dart skill 2 * 3 + dart modifier 1 * 3 = 14
    # defender: perception 7 + dexterity 7 + range 4 = 18
    @orc.should_receive(:rand).and_return(0.4374, 1)
    @orc.should_receive(:train).with('dart', 0.4375, 2)
    @orc.ranged_attack(@kobold, @map).should == "orc hits kobold"
    @kobold.hp.should == 2
  end

  it "should hit from point blank" do
    # attacker: perception 6 + dart skill 2 * 3 + dart modifier 1 * 3 = 15
    # defender: perception 7 + dexterity 7 + range 1 = 15
    @orc.perception = 6
    @orc.x = 17
    @orc.should_receive(:rand).and_return(0.4999, 1)
    @orc.should_receive(:train).with('dart', 0.5, 2)
    @orc.ranged_attack(@kobold, @map)#.should == "orc hits kobold"
    #@kobold.hp.should == 2
  end

  it "should kill" do
    @kobold.hp = 2
    @orc.should_receive(:rand).and_return(0.4374, 1)
    @orc.ranged_attack(@kobold, @map).should == "orc kills kobold"
    @kobold.hp.should == 0
  end
end
