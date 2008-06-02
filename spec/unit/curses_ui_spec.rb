require File.dirname(__FILE__) + '/../spec_helper'

describe CursesUI, "move_player" do
  it "should print '@' at current player location" do
    @ui = CursesUI.new('maps/testgame.yaml')
    @ui.game.ui.should == @ui
    @ui.game.player.x = 3

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(1, 3)
    @map_win.should_receive(:addch).with('@'[0])
    @map_win.should_receive(:refresh)
    @ui.move_player
  end

  it "should scroll down to player when he is near bottom" do
    # scroll down by 4
    map_at 0, 0
    player_at 1, 12
    @map_win.should_receive(:setpos).with(12-4, 1)
    @ui.should_receive(:redraw_map)

    @ui.move_player

    @ui.offset.should == {:x => 0, :y => 4}
  end

  it "should scroll up to player when he is near top" do
    # scroll up by 4
    map_at 0, 4
    player_at 1, 8
    @map_win.should_receive(:setpos).with(8, 1)
    @ui.should_receive(:redraw_map)

    @ui.move_player

    @ui.offset.should == {:x => 0, :y => 0}
  end

  it "should scroll down more when already scrolled by 1" do
    map_at 0, 1
    player_at 1, 13
    @map_win.should_receive(:setpos).with(13-5, 1)
    @ui.should_receive(:redraw_map)

    @ui.move_player

    @ui.offset.should == {:x => 0, :y => 5}
  end

  it "should move down only every 4 squares, so not now when offset is 4 and position is 13" do
    map_at 0, 4
    player_at 1, 13
    @map_win.should_receive(:setpos).with(13-4, 1)
    @ui.should_not_receive(:redraw_map)

    @ui.move_player
  end

  it "should scroll down not more that till bottom" do
    map_at 0, 4
    player_at 1, 16
    @map_win.should_receive(:setpos).with(16-5, 1)
    @ui.should_receive(:redraw_map)

    @ui.move_player
    @ui.offset.should == {:x => 0, :y => 5}
  end

  def map_at(x, y)
    @ui = CursesUI.new('maps/testgame.yaml')
    @ui.offset = {:x => x, :y => y}

    #@map = Map.load('maps/testmap.yaml')
    #@ui.instance_variable_set

    @map_win = mock('map_win', :maxx => 60, :maxy => 16)
    @ui.instance_variable_set :@map_win, @map_win
    @map_win.should_receive(:addch).with('@'[0])
    @map_win.should_receive(:refresh)
  end

  def player_at(x, y)
    @ui.game.player.x = x
    @ui.game.player.y = y
  end
end

describe CursesUI, "hide_player" do
  it "should unpaint player" do
    @ui = CursesUI.new('maps/testgame.yaml')

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(1, 2)
    @map_win.should_receive(:addch).with('.'[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end

  it "should unpaint player when ui has offset" do
    @ui = CursesUI.new('maps/testgame.yaml')
    @ui.offset = {:x => 2, :y => 1}

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(0, 0)
    @map_win.should_receive(:addch).with('.'[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end

  it "should unpaint player and show short sword which was under him" do
    @ui = CursesUI.new('maps/testgame.yaml')
    @ui.game.player.x = 1
    @ui.game.player.y = 1

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(1, 1)
    @map_win.should_receive(:addch).with('('[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end

  it "should unpaint player and show leather armor which was under him" do
    @ui = CursesUI.new('maps/testgame.yaml')
    @ui.game.player.x = 10
    @ui.game.player.y = 1

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(1, 10)
    @map_win.should_receive(:addch).with('['[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end
end

describe CursesUI, "draw_items (currently just items)" do
  it "should draw item (with offset)" do
    @ui = CursesUI.new('maps/testgame.yaml')
    @ui.offset = {:x => 1, :y => 5}

    @map_win = mock('map_win', :maxx => 60, :maxy => 16)
    @ui.instance_variable_set :@map_win, @map_win
    @map_win.should_receive(:setpos).with(14-5, 2-1)
    @map_win.should_receive(:addch).with('('[0])

    @ui.draw_items({"items" => ["dagger", "long sword"], "x" => 2, "y" => 14})
  end

  it "should draw leather armor" do
    @ui = CursesUI.new('maps/testgame.yaml')

    @map_win = mock('map_win', :maxx => 60, :maxy => 16)
    @ui.instance_variable_set :@map_win, @map_win
    @map_win.should_receive(:setpos).with(1, 10)
    @map_win.should_receive(:addch).with('['[0])

    @ui.draw_items({"items" => ["leather armor"], "x" => 10, "y" => 1})
  end

  it "should not draw item when it is outside of viewport" do
    @ui = CursesUI.new('maps/testgame.yaml')

    @map_win = mock('map_win', :maxx => 60, :maxy => 16)
    @ui.instance_variable_set :@map_win, @map_win
    @map_win.should_not_receive(:setpos)
    @map_win.should_not_receive(:addch)

    @ui.draw_items({"items" => ["chain mail"], "x" => 2, "y" => 16})
  end
end
