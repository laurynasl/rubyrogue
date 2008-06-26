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
