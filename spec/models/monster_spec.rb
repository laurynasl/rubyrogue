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
