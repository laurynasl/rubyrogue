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
