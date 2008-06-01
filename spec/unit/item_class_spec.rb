require File.dirname(__FILE__) + '/../spec_helper'

describe ItemClass do
  it "should create sword" do
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
end
