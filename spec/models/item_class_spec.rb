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
  end
end

describe ItemClass, 'load_all' do

  it "should load all item classes" do
    ItemClass.load_all

    short_sword = ItemClass.all['short sword']
    short_sword.class.should == ItemClass
  end
end
