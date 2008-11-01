# Copyright (C) 2008 Laurynas Liutkus
# All rights reserved. See the file named LICENSE in the distribution
# for more details.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
    game = Game.new('games/test/game.yaml')
    game.filename.should == 'games/test/game.yaml'
    game.map.name.should == 'cave-1'
    game.map.game.should === game
    game.player.name.should == 'Kudlius'

    ItemClass.all['short sword'].class.should == ItemClass
    MonsterClass.all['ogre'].class.should == MonsterClass
  end
end

describe Game, 'load (infinite)' do
  it "should load game from file" do
    game = Game.new('games/infinite/game.yaml')
    game.filename.should == 'games/infinite/game.yaml'
    game.player.name.should == 'Tourist'
    game.dungeons.size.should == 2
    game.map.name.should == 'dungeons of doom-1'
    game.map.calculate_fov
    game.player.x.should_not be_nil
    game.player.y.should_not be_nil
  end
end

describe Game, 'load_map' do
  it "should load map by name" do
    game = testgame
    game.maps['cave-1'].name.should == 'cave-1'
    game.load_map('cave-2')
    game.map.name.should == 'cave-2'
    game.map.game.should == game
  end

  it "should just switch map if it is already loaded" do
    game = testgame
    fake_map = mock('fake_map')
    game.maps['fake_map'] = fake_map
    game.load_map('fake_map')
    game.map.should == fake_map
  end

  it "should generate map because it belongs to infinite dungeon" do
    game = infinite_game
    game.load_map('dungeons of doom-2')
    game.map.name.should == 'dungeons of doom-2'
  end
end

describe Game, 'move_by' do

  before(:each) do
    @game = testgame
  end

  it "should move player to right" do
    @game.player.x.should == 2

    @game.move_by(1, 0)
    @game.player.x.should == 3
    @game.player.y.should == 1
    @game.player.energy.should == -100
  end

  it "should move player to bottom left" do
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
    @game.map.find_square(1, 1).should be_nil # empty square now is destroyed on find
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
    @game.player_square.inventory.items.first.name.should == 'short sword'
  end
end

describe Game, 'go_stairs' do
  before(:each) do
    @game = testgame
  end

  it "should go downstairs" do
    @game.player.x = 26
    @game.player.y = 2

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
    @game.go_stairs(false)
    @game.read_message.should == 'You go upstairs'
  end

  it "should display failure message when there are no square for upstairs" do
    @game.go_stairs(false)
    @game.read_message.should == 'You see no upstairs here'
  end
end

describe Game, "iterate" do
  it "should increase energy for player and monsters until player's energy reaches zero, regenerate all monsters and player and try to generate monster" do
    @game = testgame
    @game.player.energy = -2
    monster = @game.map.find_monster(11, 1)
    @game.should_receive(:move_monster).with(monster)
    @game.map.should_receive(:try_to_generate_monster)

    @game.player.should_receive(:regenerate)
    monster.should_receive(:regenerate)

    @game.iterate

    @game.player.energy.should == 9 #player's dexterity is 11
  end

  it "should iterate twice" do
    @game = testgame
    @game.player.energy = -22
    @ui.stub!(:repaint_square)
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

  [-1, 1].each do |dx|
    it "should attack player when it is near (at #{11+dx})" do
      @game.player.x = 11 + dx
      @monster.should_receive(:attack).with(@game.player).and_return('kobold misses Kudlius')
      @game.move_monster(@monster)
      @game.read_message.should == 'kobold misses Kudlius'
    end
  end
end

describe Game, "move_monster (just move)" do
  before(:each) do
    @game = testgame
    @monster = @game.map.find_monster(11, 1)
    @ui = mock('ui')
    @game.ui = @ui
  end

  it "should move monster one square right when it sees player" do
    @game.player.x = 16

    @game.move_monster(@monster)
    @monster.x.should == 12
    @monster.y.should == 1
    @monster.energy.should == -100
  end

  it "should move monster one square right when it sees player" do
    @game.player.x = 24
    @game.player.y = 4
    @monster.x = 23
    @monster.y = 1

    @game.move_monster(@monster)
    @monster.x.should == 23
    @monster.y.should == 2
  end

  it "should not move into a wall" do
    @game.player.x = 1
    @game.player.y = 4
    @monster.x = 2
    @monster.y = 1

    @game.move_monster(@monster)
    @monster.x.should == 1
    @monster.y.should == 1
  end

  it "should not move, just wait if monster cannot move anywhere" do
    @game.player.x = 9
    @game.map.tiles[1][10] = '#'[0]

    @game.move_monster(@monster)
    @monster.energy.should == -100
  end
end

describe Game, "save & restore" do
  it "should save game so that after loading it would be identic" do
    @old_game = testgame
    @old_game.save('test_fork')
    ItemClass.all = nil
    MonsterClass.all = nil
    @new_game = Game.restore('savegames/test_fork.yaml')
    @new_game.class.should == Game
    ItemClass.all['short sword'].class.should == ItemClass
    MonsterClass.all['ogre'].class.should == MonsterClass
  end

  after(:each) do
    system 'rm savegames/test_fork.yaml'
  end
end

describe Game, "kill_monster" do
  before(:each) do
    @game = testgame
    @kobold = @game.map.find_monster(11, 1)
  end

  it "should remove monster from map" do
    @kobold.inventory << 'short bow' << '5 arrows'
    @game.kill_monster(@kobold)
    @game.map.find_monster(11, 1).should be_nil
    @game.map.find_square(11, 1).inventory.collect{|item| item.to_s}.should == ['short bow', '5 arrows']
  end

  it "should drop all items it is wielding" do
    @kobold.weapon = Item.new('long sword')
    @kobold.armor = Item.new('chain mail')
    @kobold.ammunition = Item.new('15 darts')
    @game.kill_monster(@kobold)
    @game.map.find_square(11, 1).inventory.collect{|item| item.to_s}.should == ['long sword', 'chain mail', '15 darts']
  end
end

describe Game, "ranged_attack" do
  before(:each) do
    @game = testgame
    @kobold = @game.map.find_monster(11, 1)
    @game.player.x = 9
    @game.player.ammunition = Item.new('7 darts')
  end

  it "should attack monster" do
    @game.player.should_receive(:rand).and_return(0.01, 1)
    @game.ranged_attack(11, 1).should == "Kudlius hits kobold"
    @game.map.find_monster(11, 1).should == @kobold
  end

  it "should kill monster" do
    @game.player.should_receive(:rand).and_return(0.01, 1)
    @kobold.hp = 1

    @game.ranged_attack(11, 1)
    @game.map.find_monster(11, 1).should be_nil
  end

  it "should attack nobody" do
    @game.ranged_attack(9, 1).should == 'Your dart hits nobody'
    @game.map.find_square(9, 1).inventory.items.should == [Item.new('dart')]
  end
end
