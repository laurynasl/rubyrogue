require File.dirname(__FILE__) + '/../spec_helper'

describe CursesUI, "move_player" do
  it "should print '@' at current player location" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.ui.should == @ui
    @ui.game.player.x = 3

    @map_win = mock('map_win', :maxx => 60, :maxy => 16)
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

  it "should list items on the ground" do
    map_at 0, 0
    player_at 2, 14
    @map_win.should_receive(:setpos)#.with(9, 2) # I don't care about numbers at thuis test
    @ui.should_receive(:redraw_map)

    @ui.move_player
    #@ui.offset.should == {:x => 0, :y => 5}
    @ui.game.instance_variable_get(:@messages).should == ['you see here: dagger, long sword']
  end

  it "should not crash, nor move map when map is quite big" do
    map_at 0, 0, 137, 46
    player_at 2, 12
    @map_win.should_receive(:setpos)

    @ui.move_player
  end

  def map_at(x, y, maxx = 60, maxy = 16)
    @ui = CursesUI.new(TESTGAME)
    @ui.offset = {:x => x, :y => y}

    #@map = Map.load('maps/testmap.yaml')
    #@ui.instance_variable_set

    @map_win = mock('map_win', :maxx => maxx, :maxy => maxy)
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
    @ui = CursesUI.new(TESTGAME)

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(1, 2)
    @map_win.should_receive(:addch).with('.'[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end

  it "should unpaint player when ui has offset" do
    @ui = CursesUI.new(TESTGAME)
    @ui.offset = {:x => 2, :y => 1}

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(0, 0)
    @map_win.should_receive(:addch).with('.'[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end

  it "should unpaint player and show short sword which was under him" do
    @ui = CursesUI.new(TESTGAME)
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
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.x = 10
    @ui.game.player.y = 1

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(1, 10)
    @map_win.should_receive(:addch).with('['[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end

  it "should unpaint player and show staircase (no items at square)" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.x = 26
    @ui.game.player.y = 2

    @map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, @map_win

    @map_win.should_receive(:setpos).with(2, 26)
    @map_win.should_receive(:addch).with('>'[0])
    @map_win.should_receive(:refresh)
    @ui.hide_player
  end
end

describe CursesUI, "handle_input" do
  # mostly not tested...

  it "should take item from ground when clicked ','" do
    @ui = CursesUI.new(TESTGAME)

    scr = mock('scr', :getch => ','[0])
    @ui.game.should_receive(:pickup)
    @ui.handle_input(scr)
  end

  it "should show inventory when clicked 'i'" do
    @ui = CursesUI.new(TESTGAME)

    scr = mock('scr', :getch => 'i'[0])
    @ui.should_receive(:show_inventory).with(scr)
    @ui.handle_input(scr)
  end

  it "should go downstairs when clicked '>'" do
    @ui = CursesUI.new(TESTGAME)
    scr = mock('scr', :getch => '>'[0])

    @ui.game.should_receive(:go_stairs).with(true)

    @ui.handle_input(scr)
  end

  it "should go upstairs when clicked '<'" do
    @ui = CursesUI.new(TESTGAME)
    scr = mock('scr', :getch => '<'[0])

    @ui.game.should_receive(:go_stairs).with(false)

    @ui.handle_input(scr)
  end

  it "should print coordinates when clicked 'c'" do
    @ui = CursesUI.new(TESTGAME)
    scr = mock('scr', :getch => 'c'[0])

    @ui.game.should_receive(:output).with('Kudlius is at 2, 1')

    @ui.handle_input(scr)
  end
end

describe CursesUI, "show_inventory" do
  it "should show items in inventory" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor'

    scr = mock('scr')
    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    map_win.should_receive(:clear)
    map_win.should_receive(:setpos).with(0, 0)
    map_win.should_receive(:addstr).with("Inventory\n")
    map_win.should_receive(:addstr).with("Press 'z' to exit\n\n")
    map_win.should_receive(:addstr).with("short sword\n")
    map_win.should_receive(:addstr).with("leather armor\n")
    map_win.should_receive(:refresh).exactly(2)
    scr.should_receive(:getch).and_return('a'[0], 'z'[0])
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)

    @ui.show_inventory(scr)
  end
end

describe CursesUI, "redraw_map" do
  it "should at least not fail" do
    @ui = CursesUI.new(TESTGAME)
    map_win = mock('map_win', :maxx => 60, :maxy => 16, :setpos => nil, :refresh => nil, :addch => nil)
    @ui.instance_variable_set :@map_win, map_win

    @ui.redraw_map
  end
end

describe CursesUI, "repaint_square" do
  it "should repaint square" do
    @ui = CursesUI.new(TESTGAME)
    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    map_win.should_receive(:setpos).with(1, 11)
    map_win.should_receive(:addch).with('k'[0])
    map_win.should_receive(:refresh)

    @ui.repaint_square(11, 1)
  end

  it "should should repaint square (with offset)" do
    @ui = CursesUI.new(TESTGAME)
    @ui.offset = {:x => 2, :y => 1}
    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    map_win.should_receive(:setpos).with(0, 8)
    map_win.should_receive(:addch).with('['[0])
    map_win.should_receive(:refresh)

    @ui.repaint_square(10, 1)
  end
end

describe CursesUI, 'game_loop' do
  it "should call game.iterate after handling input" do
    @ui = CursesUI.new(TESTGAME)
    @ui.should_receive(:draw_windows)
    @ui.should_receive(:handle_input).and_return(false)
    @ui.game.should_receive(:iterate)
    mess_win = mock('mess_win')
    @ui.instance_variable_set(:@mess_win, mess_win)
    mess_win.should_receive(:refresh)
    @ui.should_receive(:draw_attributes)

    @ui.game_loop
  end
end

describe CursesUI, "draw_attributes" do
  it "should draw_attributes" do
    @ui = CursesUI.new(TESTGAME)
    @att_win = mock('att_win')
    @ui.instance_variable_set(:@att_win, @att_win)

    @att_win.should_receive(:clear)
    @att_win.should_receive(:setpos).with(0, 0)
    @att_win.should_receive(:addstr).with("Health 10/10\n")
    @att_win.should_receive(:addstr).with("Dexterity 11\n")
    @att_win.should_receive(:addstr).with("Perception 7\n")
    @att_win.should_receive(:addstr).with("Health 10\n")
    @att_win.should_receive(:refresh)

    @ui.draw_attributes
  end
end
