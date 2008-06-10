require File.dirname(__FILE__) + '/../spec_helper'

def square_with_items
  Square.new(
    'x' => 3,
    'y' => 17,
    'items' => ['short sword', 'leather armor']
  )
end

def square_with_stairs_down
  Square.new(
    'x' => 3,
    'y' => 17,
    'stair' => {
      'map' => 'cave-2',
      'x' => 3,
      'y' => 2,
      'down' => true
    }
  )
end

def square_with_stairs_up
  Square.new(
    'x' => 3,
    'y' => 17,
    'stair' => {
      'map' => 'cave-2',
      'x' => 3,
      'y' => 2,
      'down' => false
    }
  )
end

describe Square do
  it "should initialize with x, y, and items" do
    @square = square_with_items
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

describe Square, "look" do
  it "should show items list" do
    @square = square_with_items
    @square.look.should == "you see here: short sword, leather armor"
  end

  it "should show downstairs" do
    @square = square_with_stairs_down
    @square.look.should == "you see here: downstairs"
  end

  it "should show upstairs" do
    @square = square_with_stairs_up
    @square.look.should == "you see here: upstairs"
  end
end
