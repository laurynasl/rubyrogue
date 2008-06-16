require File.dirname(__FILE__) + '/../spec_helper'

describe Monster do
  before(:each) do
    @monster = Monster.new({
      'x' => 10,
      'y' => 1,
      'monster_type' => 'kobold',
      'maxhp' => 5,
      'hp' => 4,
      'dexterity' => 7
    })
  end
  it "should load monster" do
    @monster.x.should == 10
    @monster.y.should == 1
    @monster.maxhp.should == 5
    @monster.hp.should == 4
    @monster.inventory.should be_an_instance_of(Inventory)
  end

  it "should fail to create monster without hp" do
    lambda {
      Monster.new 'maxhp' => 5
    }.should raise_error(RuntimeError, 'hp is required!')
  end

  it "should be valid" do
    @monster.validate!
  end

  it_should_have_fields :monster, 'dexterity', 'hp', 'maxhp'
end

describe Monster, "fullname" do
  before(:each) do
    @monster = Monster.new(
      'hp' => 9,
      'maxhp' => 9,
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
      'maxhp' => 9,
      'dexterity' => 9,
      'monster_type' => 'orc'
    )
    @defender = Monster.new(
      'hp' => 4,
      'maxhp' => 4,
      'dexterity' => 7,
      'monster_type' => 'kobold'
    )
  end

  it "should attack and miss" do
    @attacker.should_receive(:rand).and_return(0.5625)
    @attacker.attack(@defender).should == "orc misses kobold"
  end

  it "should attack and hit" do
    @attacker.should_receive(:rand).and_return(0.5624)
    @attacker.attack(@defender).should == "orc hits kobold"
  end
end
