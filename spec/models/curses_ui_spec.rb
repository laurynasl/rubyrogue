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

  it "should drop item when clicked 'd'" do
    @ui = CursesUI.new(TESTGAME)

    scr = mock('scr', :getch => 'd'[0])
    @ui.should_receive(:drop_item).with(scr)
    @ui.handle_input(scr)
  end

  it "should let to manage equipment when clicked 'e'" do
    @ui = CursesUI.new(TESTGAME)

    scr = mock('scr', :getch => 'e'[0])
    @ui.should_receive(:manage_equipment).with(scr)
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

  it "should save game when clicked 'S'" do
    @ui = CursesUI.new(TESTGAME)
    scr = mock('scr', :getch => 'S'[0])

    @ui.game.should_receive(:save).with('Kudlius')

    @ui.handle_input(scr).should be_false

  end

  it "should start targeting when clicked 'f'" do
    @ui = CursesUI.new(TESTGAME)
    scr = mock('scr', :getch => 'f'[0])

    @ui.should_receive(:target_and_shoot).with(scr)

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
    @ui.should_receive(:print_inventory)
    scr.should_receive(:getch).and_return('a'[0], 'z'[0])
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)
    map_win.should_receive(:refresh)

    @ui.show_inventory(scr)
  end

  it "should print inventory" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor'

    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    map_win.should_receive(:clear)
    map_win.should_receive(:setpos).with(0, 0)
    map_win.should_receive(:addstr).with("Inventory\n")
    map_win.should_receive(:addstr).with("Press 'z' to exit\n\n")
    map_win.should_receive(:addstr).with("A short sword\n")
    map_win.should_receive(:addstr).with("B leather armor\n")
    map_win.should_receive(:refresh)

    @ui.print_inventory
  end

  it "should print filtered inventory" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor'

    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    map_win.should_receive(:clear)
    map_win.should_receive(:setpos).with(0, 0)
    map_win.should_receive(:addstr).with("Inventory\n")
    map_win.should_receive(:addstr).with("Press 'z' to exit\n\n")
    map_win.should_receive(:addstr).with("A short sword\n")
    map_win.should_receive(:refresh)

    @ui.print_inventory('weapon')
  end
end

describe CursesUI, "manage_equipment" do
  it "should show equipped items and let to equip weapon" do
    do_it('short sword', 'weapon', 'a')
  end

  it "should let to equip armor" do
    do_it('leather armor', 'armor', 'b')
  end

  it "should let to unequip weapon" do
    do_unequip('dagger', 'weapon', 'a')
  end

  it "should let to equip launcher" do
    do_it('short bow', 'launcher', 'c')
  end

  it "should let to equip ammunition" do
    do_it('14 darts', 'ammunition', 'd')
  end

  def do_it(item_name, slot, letter)
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << item_name

    @scr = mock('scr')
    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    @ui.should_receive(:print_equipment).exactly(2).times
    @scr.should_receive(:getch).and_return(letter[0], 'z'[0])
    @ui.should_receive(:select_item).with(@scr, slot.to_sym).and_return(0) # should be short sword
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)
    map_win.should_receive(:refresh)

    @ui.manage_equipment(@scr)
  end

  def do_unequip(item_name, slot, letter)
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.send(slot + '=', item_name)

    @scr = mock('scr')
    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win
    @ui.should_receive(:print_equipment).exactly(2).times
    @scr.should_receive(:getch).and_return(letter[0], 'z'[0])
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)
    map_win.should_receive(:refresh)

    @ui.manage_equipment(@scr)

    @ui.game.player.send(slot).should be_nil
  end

  it "should display filtered by slot items and then player should select one" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor' << 'dagger'
    @scr = mock('scr')
    @map_win = mock('map_win', :refresh => nil)
    @ui.instance_variable_set :@map_win, @map_win
    @ui.should_receive(:print_equipment).exactly(2).times
    @ui.should_receive(:print_inventory).with(:weapon)
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)
    @scr.should_receive(:getch).and_return('a'[0], 'b'[0], 'z'[0])

    @ui.manage_equipment(@scr)
    @ui.game.player.weapon.to_s.should == 'dagger'
  end
end

describe CursesUI, "print_equipment" do
  it "should print equipment" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.weapon = Item.new('short sword')
    @ui.game.player.armor = Item.new('leather armor')
    @ui.game.player.launcher = Item.new('short bow')
    @ui.game.player.ammunition = Item.new('19 arrows')
    map_win = mock('map_win')
    @ui.instance_variable_set :@map_win, map_win

    map_win.should_receive(:clear)
    map_win.should_receive(:setpos).with(0, 0)
    map_win.should_receive(:addstr).with("Equipment\n")
    map_win.should_receive(:addstr).with("Press 'z' to exit\n\n")
    map_win.should_receive(:addstr).with("A Weapon: short sword\n")
    map_win.should_receive(:addstr).with("B Armor: leather armor\n")
    map_win.should_receive(:addstr).with("C Launcher: short bow\n")
    map_win.should_receive(:addstr).with("D Ammunition: 19 arrows\n")
    map_win.should_receive(:refresh)

    @ui.print_equipment
  end
end

describe CursesUI, "select_item" do
  it "should select item and return it's index" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor'
    @ui.should_receive(:print_inventory)
    scr = mock('scr')
    scr.should_receive(:getch).and_return('b'[0])

    @ui.select_item(scr).should == 1
  end
end

describe CursesUI, "redraw_map" do
  it "should at least not fail" do
    @ui = CursesUI.new(TESTGAME)
    map_win = mock('map_win', :maxx => 60, :maxy => 16, :setpos => nil, :refresh => nil, :addch => nil, :attrset => nil)
    @ui.instance_variable_set :@map_win, map_win

    @ui.redraw_map
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
    @ui.should_receive(:redraw_map)
    @ui.should_receive(:move_player)
    @ui.should_receive(:draw_attributes)

    @ui.game_loop
  end

  it "should end in player death" do
    @ui = CursesUI.new(TESTGAME)
    @ui.should_receive(:draw_windows)
    @ui.should_receive(:handle_input).and_return(true)
    @ui.game.should_receive(:iterate).and_throw(:player_death)
    mess_win = mock('mess_win')
    @ui.instance_variable_set(:@mess_win, mess_win)
    mess_win.should_receive(:refresh)
    #@ui.should_receive(:redraw_map)
    #@ui.should_receive(:move_player)
    #@ui.should_receive(:draw_attributes)

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

describe CursesUI, "restore game" do
  it "should load game using YAML if it is savegame" do
    @old_game = testgame
    @old_game.save 'test_for_curses_ui'
    
    @ui = CursesUI.new('savegames/test_for_curses_ui.yaml')
    @ui.game.class.should == Game
    @ui.game.map.name.should == 'cave-1'
    @ui.game.ui.should == @ui
  end
end

describe CursesUI, "print_char" do
  [[:white, Curses::COLOR_WHITE], [:yellow, Curses::COLOR_YELLOW]].each do |color, constant|
    it "should print #{color} character to map win" do
      @ui = CursesUI.new(TESTGAME)
      @map_win = mock('map_win')
      @ui.instance_variable_set(:@map_win, @map_win)
      @map_win.should_receive(:attrset).with(Curses.color_pair(constant))
      @map_win.should_receive(:addch).with('.'[0])

      @ui.print_char([color, '.'[0]])
    end
  end
end

describe CursesUI, "target_and_shoot" do
  include Curses
  it "should find and pre-target nearest monster, then allow player to move aim to other monster and fire at it" do
    @ui = CursesUI.new(TESTGAME)
    @map_win = mock('map_win')
    @ui.instance_variable_set(:@map_win, @map_win)
    @game = @ui.game
    @game.player.x = 24
    @game.player.y = 3
    orc('x' => 27, 'y' => 8)
    kobold('x' => 22, 'y' => 1)
    @game.map.monsters << @orc
    @game.map.monsters << @kobold
    @game.player.ammunition = Item.new('15 darts')

    @scr = mock('scr')
    @scr.should_receive(:getch).and_return(KEY_DOWN, KEY_DOWN, KEY_DOWN, KEY_DOWN, KEY_DOWN, KEY_DOWN, KEY_DOWN, KEY_RIGHT, KEY_RIGHT, KEY_RIGHT, KEY_RIGHT, KEY_RIGHT, 'f'[0])
    @game.map.should_receive(:find_nearest_visible_monster).and_return(@kobold)
    @map_win.stub!(:setpos)
    Curses.should_receive(:curs_set).with(1)
    @map_win.should_receive(:refresh).exactly(13).times
    Curses.should_receive(:curs_set).with(0)
    @game.player.should_receive(:ranged_attack).with(@orc, @game.map).and_return("Kudlius misses orc")

    @ui.target_and_shoot(@scr)
    @game.read_message.should == "Kudlius misses orc"
  end

  it "should find nothing to shoot at" do
    @ui = CursesUI.new(TESTGAME)
    @map_win = mock('map_win')
    @ui.instance_variable_set(:@map_win, @map_win)
    @game = @ui.game
    @game.player.ammunition = Item.new('15 darts')

    @scr = mock('scr')
    @scr.should_receive(:getch).and_return(KEY_DOWN, 'z'[0])
    @game.map.should_receive(:find_nearest_visible_monster).and_return(nil)
    @map_win.stub!(:setpos)
    Curses.should_receive(:curs_set).with(1)
    @map_win.should_receive(:refresh).exactly(2).times
    Curses.should_receive(:curs_set).with(0)

    @ui.target_and_shoot(@scr)
  end

  it "should refuse targeting if player has no ammunition readied" do
    @ui = CursesUI.new(TESTGAME)
    #@map_win = mock('map_win')
    #@ui.instance_variable_set(:@map_win, @map_win)
    #@game = @ui.game

    @ui.target_and_shoot(@scr)
    @ui.game.read_message.should == "You have no ammunition readied"
  end

  it "should refuse targeting if player has no ammunition readied" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.ammunition = Item.new('11 rocks')
    @ui.game.player.launcher = Item.new('short bow')

    @ui.target_and_shoot(@scr)
    @ui.game.read_message.should == "You cannot shoot rocks using short bow"
  end

  it "should target and shoot using short bow and arrows" do
    stubbed_ui
    @game.player.x = 24
    @game.player.y = 3
    orc('x' => 27, 'y' => 8)
    @game.map.monsters << @orc
    @game.player.ammunition = Item.new('15 arrows')
    @game.player.launcher = Item.new('short bow')

    @scr = mock('scr')
    @scr.should_receive(:getch).and_return('f'[0])
    @game.map.should_receive(:find_nearest_visible_monster).and_return(@orc)
    Curses.should_receive(:curs_set).with(1)
    Curses.should_receive(:curs_set).with(0)
    @game.player.should_receive(:ranged_attack).with(@orc, @game.map).and_return("Kudlius misses orc")

    @ui.target_and_shoot(@scr)
    @game.read_message.should == "Kudlius misses orc"
  end
end

describe CursesUI, "recognize_move" do
  it "should return key, transformed into [dx,dy] for movement and key for other keys" do
    @ui = CursesUI.new(TESTGAME)

    @ui.recognize_move(KEY_DOWN).should == [0, 1]
    @ui.recognize_move(KEY_UP).should == [0, -1]
    @ui.recognize_move(KEY_LEFT).should == [-1, 0]
    @ui.recognize_move(KEY_RIGHT).should == [1, 0]
    @ui.recognize_move('a'[0]).should == 'a'[0]
  end
end

describe CursesUI, "drop_item" do
  it "should print inventory, read letter and drop item" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor'
    @scr = mock('scr')

    @ui.should_receive(:select_item).with(@scr).and_return(1) #leather armor

    @ui.drop_item(@scr)

    @ui.game.player.inventory.items.size.should == 1
    square = @ui.game.map.find_square(2, 1)
    square.inventory.items.size.should == 1
    square.inventory.items[0].to_s.should == 'leather armor'
  end

  it "should drop nothing if no item selected" do
    @ui = CursesUI.new(TESTGAME)
    @ui.game.player.inventory << 'short sword' << 'leather armor'
    @scr = mock('scr')

    @ui.should_receive(:select_item).with(@scr).and_return(3) #nothing

    @ui.drop_item(@scr)

    @ui.game.player.inventory.items.size.should == 2
    @ui.game.map.find_square(2, 1).should be_nil
  end
end
