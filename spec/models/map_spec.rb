require File.dirname(__FILE__) + '/../spec_helper'

describe Map, 'load' do
  it "should load map from file" do
    @map = Map.load(TESTMAP)
    @map.name.should == 'testmap'
    @map.tiles.size.should == 21
    @map.tiles[1].should == "#...........................############\n"
    @map.width.should == 40
    @map.height.should == 21
  end
end

describe Map, 'find_square' do
  it "should find square" do
    @map = Map.load(TESTMAP)
    @map.find_square(1, 1).should == {'x' => 1, 'y' => 1, 'items' => ['short sword']}
  end
end
