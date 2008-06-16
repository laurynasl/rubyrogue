require File.dirname(__FILE__) + '/../spec_helper'

describe Monster do
  it "should load player" do
    monster = Monster.new({
      'x' => 10,
      'y' => 1,
      'monster_type' => 'kobold',
      'maxhp' => 5,
      'hp' => 4
    })
    monster.x.should == 10
    monster.y.should == 1
    monster.maxhp.should == 5
    monster.hp.should == 4
    monster.inventory.should be_an_instance_of(Inventory)
  end
end

describe Monster, "fullname" do
  before(:each) do
    @monster = Monster.new(
      'hp' => 9,
      'dexterity' => 9,
      'monster_type' => 'orc'
    )
  end

  it "should return monster_type" do
    @monster.fullname.should == 'orc'
  end

  it "should return name when it is present" do
    @monster.name = 'Sigmund'
    @monster.fullname.should == 'Sigmund'
  end
end

describe Monster, "attack" do
  before(:each) do
    @attacker = Monster.new(
      'hp' => 9,
      'dexterity' => 9,
      'monster_type' => 'orc'
    )
    @defender = Monster.new(
      'hp' => 4,
      'dexterity' => 7,
      'monster_type' => 'kobold'
    )
  end

  it "should attack and miss" do
    @attacker.attack(@defender).should == "orc misses kobold"

  end
end
