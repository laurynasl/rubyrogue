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
    @monster.energy.should == 0
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
    orc
    kobold
  end

  it "should attack and miss" do
    @orc.should_receive(:rand).and_return(0.5625)
    @orc.attack(@kobold).should == "orc misses kobold"
  end

  it "should attack and hit" do
    @orc.should_receive(:rand).and_return(0.5624, 1)
    #@orc.should_receive(:rand).with(2).and_return(1)
    @orc.attack(@kobold).should == "orc hits kobold"
    @kobold.hp.should == 2
  end

  it "should attack and kill" do
    @kobold.hp = 2
    @orc.should_receive(:rand).and_return(0.5624, 1)
    @orc.attack(@kobold).should == "orc kills kobold"
    @kobold.hp.should == 0
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
