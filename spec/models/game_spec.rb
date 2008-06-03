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

    short_sword = game.item_classes['short sword']
    short_sword.should be_instance_of(ItemClass)
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
    @ui.should_receive(:hide_player)
    @ui.should_receive(:move_player)

    @game.move_by(1, 0)
    @game.player.x.should == 3
    @game.player.y.should == 1
  end

  it "should move player to bottom left" do
    @ui.should_receive(:hide_player)
    @ui.should_receive(:move_player)
    @game.move_by(-1, 1)

    @game.player.x.should == 1
    @game.player.y.should == 2
  end

  it "should forbid moving into wall" do
    @ui.should_not_receive(:hide_player)
    @ui.should_not_receive(:move_player)
    @game.move_by(1, 1)
    @game.instance_variable_get(:@messages).should == ["Ouch. You bump into a wall."]
  end
end

describe Game, "pickup" do
  before(:each) do
    @game = testgame
    @ui = mock('CursesUI')
    @game.ui = @ui
  end

  it "should pick up short sword, then have it in inventory and there should be no short sword on the ground" do
    @game.player.x = 1
    @game.player.inventory.should_not include('short sword')
    @game.pickup
    @game.player.inventory.should include('short sword')
    #@game.map.find_square(1, 1)['items'].should == [] # possibly this is better, but... YAGNI
    @game.map.find_square(1, 1).should be_nil
    @game.read_message.should == 'You pick up short sword'
  end

  it "should pick up dagger and long sword after having got chain mail somewhere" do
    @game.player.x = 2
    @game.player.y = 14
    @game.player.inventory << 'chain mail'
    @game.pickup
    @game.player.inventory.should include('dagger')
    @game.player.inventory.should include('long sword')
    @game.read_message.should == 'You pick up dagger, long sword'
  end

  it "should not pick up anything, because there is nothing..." do
    @game.pickup
    @game.read_message.should == 'There is nothing to pick up'
  end
end
