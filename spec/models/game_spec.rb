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
    game.filename.should == 'games/test/game.yaml'
    game.map.name.should == 'cave-1'
    game.map.game.should === game
    game.player.name.should == 'Kudlius'

    short_sword = game.item_classes['short sword']
    short_sword.should be_instance_of(ItemClass)
  end
end

describe Game, 'load_map' do
  it "should load map by name" do
    game = testgame
    game.load_map('cave-2')
    game.map.name.should == 'cave-2'
    game.map.game.should == game
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
    @game.player.energy.should == -100
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
    @game.player.energy.should == 0
  end

  it "should attack monster" do
    @game.player.x = 10
    @game.player.should_receive(:attack).with(@game.map.find_monster(11, 1)).and_return('Kudlius misses kobold')

    @game.move_by(1, 0)

    @game.read_message.should == 'Kudlius misses kobold'
  end

  it "should kill monster and remove it from map" do
    @game.player.x = 10
    @game.map.find_monster(11, 1).hp = 2
    @game.player.should_receive(:rand).and_return(0, 1) # hit and do damage 2 (1 + 1)
    @ui.should_receive(:repaint_square).with(11, 1)

    @game.move_by(1, 0)

    @game.read_message.should == 'Kudlius kills kobold'
    @game.map.find_monster(11, 1).should be_nil
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
    @game.map.find_square(1, 1).items.should be_empty
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

describe Game, 'player_square' do
  it "should be a simple shortcut to Map#find_square" do
    @game = testgame
    @game.player.x = 1
    @game.player.y = 1
    @game.player_square.items.first.name.should == 'short sword'
  end
end

describe Game, 'go_stairs' do
  before(:each) do
    @game = testgame
    @ui = mock('ui')
    @game.ui = @ui
  end

  it "should go downstairs" do
    @game.player.x = 26
    @game.player.y = 2
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)

    @game.go_stairs(true)

    @game.map.name.should == 'cave-2'
    @game.player.x.should == 3
    @game.player.y.should == 2
    @game.read_message.should == 'You go downstairs'
  end

  it "should display failure message when there are no square" do
    @game.go_stairs(true)
    @game.read_message.should == 'You see no downstairs here'
  end

  it "should display failure message when square has no stairs" do
    @game.player.x = 1
    @game.go_stairs(true)
    @game.read_message.should == 'You see no downstairs here'
  end

  it "should display failure message when stair is not downstair" do
    @game.player.x = 26
    @game.player.y = 2
    @game.player_square.stair['down'] = false
    @game.go_stairs(true)
    @game.read_message.should == 'You see no downstairs here'
  end

  it "should go upstairs" do
    @game.player.x = 26
    @game.player.y = 2
    @game.player_square.stair['down'] = false
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)
    @game.go_stairs(false)
    @game.read_message.should == 'You go upstairs'
  end

  it "should display failure message when there are no square for upstairs" do
    @game.go_stairs(false)
    @game.read_message.should == 'You see no upstairs here'
  end
end

describe Game, "iterate" do
  it "should increase energy for player and monsters until player's energy reaches zero" do
    @game = testgame
    @game.player.energy = -2
    monster = @game.map.find_monster(11, 1)
    @game.should_receive(:move_monster).with(monster)
    @game.iterate

    @game.player.energy.should == 9 #player's dexterity is 11
  end

  it "should iterate twice" do
    @game = testgame
    @game.player.energy = -22
    @game.iterate

    @game.player.energy.should == 0
    @game.map.find_monster(11, 1).energy.should == -86
  end
end

describe Game, "move_monster" do
  before(:each) do
    @game = testgame
    @monster = @game.map.find_monster(11, 1)
  end

  it "should wait if there's nothing else to do" do
    @monster.should_receive(:wait)
    @game.move_monster(@monster)
  end

  it "should attack player when it is near" do
    @game.player.x = 10
    @monster.should_receive(:attack).with(@game.player).and_return('kobold misses Kudlius')
    @game.move_monster(@monster)
    @game.read_message.should == 'kobold misses Kudlius'
  end
end
