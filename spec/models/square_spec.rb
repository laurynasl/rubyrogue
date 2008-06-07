require File.dirname(__FILE__) + '/../spec_helper'

describe Square do
  it "should initialize with x, y, and items" do
    @square = Square.new(
      'x' => 3,
      'y' => 17,
      'items' => ['short sword', 'leather armor']
    )
    @square.x.should == 3
    @square.y.should == 17
    @square.items[0].name.should == 'short sword'
    @square.items[1].name.should == 'leather armor'
    @square.item_names.should == ['short sword', 'leather armor']
  end

  it "should have attribute 'stair'" do
    @square = Square.new(
      'x' => 1,
      'y' => 2,
      'stair' => {
        'map' => 'cave-2',
        'x' => 5,
        'y' => 7,
        'down' => true
      }
    )
    @square.items.should == []
  end
end
