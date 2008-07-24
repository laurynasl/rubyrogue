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

#!/usr/bin/ruby

require "curses"
include Curses

def show_message(*msgs)
  message = msgs.join
  width = message.length + 6
  win = Window.new(5, width,
		   (lines - 5) / 2, (cols - width) / 2)
  win.keypad = true
  win.attron(color_pair(COLOR_RED)){
    win.box(?|, ?-, ?+)
  }
  win.setpos(2, 3)
  win.addstr(message)
  win.refresh
  win.getch
  win.close
end

init_screen
start_color
init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_WHITE)
init_pair(COLOR_RED,COLOR_RED,COLOR_WHITE)
crmode
noecho
stdscr.keypad(true)

begin
  mousemask(BUTTON1_CLICKED|BUTTON2_CLICKED|BUTTON3_CLICKED|BUTTON4_CLICKED)
  setpos((lines - 5) / 2, (cols - 10) / 2)
  attron(color_pair(COLOR_BLUE)|A_BOLD){
    addstr("click")
  }
  refresh
  while( true )
    c = getch
    case c
    when KEY_MOUSE
      m = getmouse
      if( m )
	show_message("getch = #{c.inspect}, ",
		     "mouse event = #{'0x%x' % m.bstate}, ",
		     "axis = (#{m.x},#{m.y},#{m.z})")
      end
      break
    end
  end
  refresh
ensure
  close_screen
end
