require File.dirname(__FILE__) + '/../spec_helper'

describe Map, 'load' do
  it "should load map from file" do
    @map = Map.load(TESTMAP)
    @map.name.should == 'cave-1'
    @map.tiles.size.should == 21
    @map.tiles[1].should == "#...........................############\n"
    @map.width.should == 40
    @map.height.should == 21
    @map.squares.should_not be_nil
  end
end

describe Map, 'find_square' do
  it "should find square" do
    @map = Map.load(TESTMAP)
    square = @map.find_square(1, 1) #.should == {'x' => 1, 'y' => 1, 'items' => ['short sword']}
    square.should be_instance_of(Square)
    square.x.should == 1
    square.y.should == 1
    square.items.first.name.should == 'short sword'
  end
end

describe Map, "square_symbol_at" do
  before(:each) do
    @game = testgame
    @map = @game.map
  end

  it "should return background" do
    @map.square_symbol_at(3, 1).should be_char('.')
    @map.square_symbol_at(3, 2).should be_char('#')
    #@map.square_symbol_at(2, 1).should be_char('@')
    @map.square_symbol_at(2, 14).should be_char('(')
    @map.square_symbol_at(10, 1).should be_char('[')
    @map.square_symbol_at(26, 2).should be_char('>')
  end

  it "should return space when square is outside of map" do
    @map.square_symbol_at(100, 1).should be_char(' ')
    @map.square_symbol_at(1, 100).should be_char(' ')
  end
end
