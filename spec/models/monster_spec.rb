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

  it_should_have_fields :kobold, 'dexterity', 'perception', 'health', 'hp', 'maxhp'
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
    @orc.attack(@kobold)
  end

  it "should inflict damage of maximum 5 when attacking with short sword" do
    ItemClass.load_all
    @orc.weapon = Item.new('short sword')
    @orc.should_receive(:rand).and_return(0.5624)
    @orc.should_receive(:inflict_damage).with(@kobold, 5).and_return(3)
    @orc.attack(@kobold)
  end
end

describe Monster, "inflict_damage" do
  it "should inflict damage of maximum 2 when without a weapon" do
    orc
    kobold
    @orc.should_receive(:rand).with(3).and_return(1)
    @orc.inflict_damage(@kobold, 3)
    @kobold.hp.should == 2
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
