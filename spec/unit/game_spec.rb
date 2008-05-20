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
    game = testgame
    game.map.name.should == 'testmap'
    game.player.name.should == 'Kudlius'
  end
end

describe Game, 'move_by' do

  before(:each) do
    @game = testgame
    @ui = mock('CursesUI')
    @game.ui = @ui
  end

  it "should move player to right" do
    @game.player.x.should == 2
    @ui.should_receive(:move_player)

    @game.move_by(1, 0)
    @game.player.x.should == 3
    @game.player.y.should == 1
  end

  it "should move player to bottom left" do
    @ui.should_receive(:move_player)
    @game.move_by(-1, 1)

    @game.player.x.should == 1
    @game.player.y.should == 2
  end
end
