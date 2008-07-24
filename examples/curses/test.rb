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

require 'curses'
include Curses

class Window

end

init_screen
noecho
begin
  crmode

  while true
    c = getch
    if keyname(c) == 'q'
      break
    elsif c == KEY_RESIZE
      clear
      addstr sprintf("resized to: (%d,%d)\n", lines, cols)
    end
    refresh
  end
ensure
  close_screen
end
