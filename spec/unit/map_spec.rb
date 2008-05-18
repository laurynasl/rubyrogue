require File.dirname(__FILE__) + '/../spec_helper'

describe Map, 'load' do
  it "should load map from file" do
    @map = Map.load('maps/testmap.yaml')
    @map.name.should == 'testmap'
    @map.tiles.size.should == 20
    @map.tiles[1].should == "#...........................############\n"
  end
end

