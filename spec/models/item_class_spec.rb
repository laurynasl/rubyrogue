require File.dirname(__FILE__) + '/../spec_helper'

describe ItemClass do
  it "should create short sword" do
    @item = ItemClass.new 'short sword', {
      'damage' => 5,
      'accuracy' => 0,
      'symbol' => '(',
      'skills' => ['slashing', 'sword']
    }
    @item.damage.should == 5
    @item.accuracy.should == 0
    @item.symbol.should == '('
    @item.skills.should == ['slashing', 'sword']
  end

  it "should create leather armor" do
    @item = ItemClass.new 'short sword', {
      'armor' => 3,
      'evasion' => 1,
      'symbol' => '[',
      'skills' => ['stealth', 'evasion']
    }
    #@item.armor.should == 3
    #@item.evasion.should == 1
    #@item.symbol.should == '('
    #@item.skills.should == ['stealth', 'evasion']
  end
end
