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

def show_message(message)
  width = message.length + 6
  win = Window.new(5, width, (lines - 5) / 2, (cols - width) / 2)
  win.box(?|, ?-)
  win.setpos(2, 3)
  win.addstr(message)
  win.refresh
  #win.getch
  win.close
end

def size
  "(#{cols},#{lines})"
end

init_screen
noecho
begin
  crmode
#  show_message("Hit any key")
  setpos((lines - 5) / 2, (cols - 10) / 2)
  addstr("Hit any key" + size)
  refresh
  while true
    c = getch
    if keyname(c) == 'q'
      break
    end
    show_message("Hello, World! " + keyname(c) + c.to_s + size)
    refresh
  end
ensure
  close_screen
end
