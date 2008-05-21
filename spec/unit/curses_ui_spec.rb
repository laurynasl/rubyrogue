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
end
