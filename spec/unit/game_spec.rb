require File.dirname(__FILE__) + '/../spec_helper'

describe Game, "messages" do
  it "should return nil when there are no messages" do
    game = Game.new
    game.read_message.should be_nil
  end

  it "should write messages to queue and then return them" do
    game = Game.new
    game.output('text')
    game.output('more text')
    game.read_message.should == 'text'
    game.read_message.should == 'more text'
    game.read_message.should be_nil
  end
end

describe Game, 'load' do
  it "should load game from file" do
    game = Game.new('maps/testgame.yaml')
    game.map.name.should == 'testmap'
    game.player.name.should == 'Kudlius'
  end
end
