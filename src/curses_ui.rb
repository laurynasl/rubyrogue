require 'curses'

include Curses

class CursesUI
  attr_accessor :game, :offset
  MESS_HEIGHT = 6
  ATT_WIDTH = 18
  def initialize(filename = nil)
    # Init the action map
    init_actions
    @offset = {:x => 0, :y => 0}

    # Init game
    @game = Game.new(filename)
    @game.ui = self
  end

  ##
  # Draws the game windows
  #
  def draw_windows
    @scr = Curses.init_screen
    Curses.start_color
    Curses.raw
    Curses.noecho
    Curses.curs_set(0)
    @scr.keypad(true)
    @scr.refresh

    # Color pairs definitions
    Curses.init_pair(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK);
    Curses.init_pair(COLOR_GREEN, COLOR_GREEN, COLOR_BLACK);
    Curses.init_pair(COLOR_RED, COLOR_RED, COLOR_BLACK);
    Curses.init_pair(COLOR_CYAN, COLOR_CYAN, COLOR_BLACK);
    Curses.init_pair(COLOR_WHITE, COLOR_WHITE, COLOR_BLACK);
    Curses.init_pair(COLOR_MAGENTA, COLOR_MAGENTA, COLOR_BLACK);
    Curses.init_pair(COLOR_BLUE, COLOR_BLUE, COLOR_BLACK);
    Curses.init_pair(COLOR_YELLOW, COLOR_YELLOW, COLOR_BLACK);

    @width = cols > 80 ? cols : 80
    @height = lines > 24 ? lines : 24

    att_w = ATT_WIDTH+2
    mess_h = MESS_HEIGHT+2
    att_h = @height - mess_h
    mess_w = @width

    # Map window
    @map_win = Window.new(@height - mess_h, @width - att_w, 0, att_w)
    if @game.map
      redraw_map
    end
    @map_win.refresh
    move_player

    # Attributes window
    border_win = Window.new(att_h, att_w, 0, 0)
    border_win.box(0,0)
    border_win << 'Attrs'
    border_win.refresh
    @att_win = Window.new(att_h-2, att_w-2, 1, 1)
    @att_win.refresh

    # Messages window
    border_win = Window.new(mess_h, mess_w, att_h, 0)
    border_win.box(0,0)
    border_win << "Messages"
    border_win.refresh
    @mess_win = Window.new(mess_h-2, mess_w-2, att_h+1, 1)
    @mess_win.scrollok(true)
    @mess_win.refresh
  end

  def redraw_map
    @game.output @map_win.maxx.to_s + 'x' + @map_win.maxy.to_s
    @map_win.setpos 0, 0
    @map_win.maxy.times do |y|
      @map_win.maxx.times do |x|
        begin
          @map_win.addch @game.map.tiles[@offset[:y]+y][@offset[:x]+x]
        rescue
#           @game.output('Error: ' + $!.to_s)
        end
      end
    end
    @game.map.data['squares'].each do |square|
      draw_items square
    end
  end

  ##
  # Does the game loop (including key reading and dispatching)
  #
  def game_loop
    # Draws the windows
    draw_windows

    # Loop controller
    playing = true

    # Draw the screen first time
    #x = @game.player.x
    #y = @game.player.y
    #draw_all(@map_win, x, y)

    # Real game loop
    while playing do
      # First, we show all queued messages
      while m = @game.read_message do
        draw_message(@mess_win, m)
      end
      @mess_win.refresh

      playing = handle_input(@scr)

      # Launches the game logics
      #@game.iterate

      #x = @game.player.x
      #y = @game.player.y
      #draw_all(@map_win, x, y)
    end
  ensure
    close_screen
  end


  # Work out the input
  def handle_input(scr)
    keep_playing = true
    key = scr.getch
    if (@@show_stoppers.include?(key))
      keep_playing = false
    elsif key == KEY_RESIZE
      close_screen
      draw_windows
    else
      begin
        case key
        when KEY_UP: 
          @game.move_by(0, -1)
        when KEY_DOWN: 
          @game.move_by(0, 1)
        when KEY_LEFT: 
          @game.move_by(-1, 0)
        when KEY_RIGHT: 
          @game.move_by(1, 0)
        else
          @game.output keyname(key) || key
        end
      rescue
        puts $!.to_s
        puts $!.backtrace.join("\n")
        @game.output $!.to_s
      end
    end
    return keep_playing
  end

  ##
  # Initialize a map of key / actions
  # For each key, the first actions whose test matches will be called.
  def init_actions
    # These are the keys whose only purpose is
    # to terminate the game.
    @@show_stoppers = [KEY_F2, 'q'[0]]
  end

  ##
  # Shows the text in the message window
  #
  def draw_message(win, m)
    win << m + "\n"
    win.scroll if win.cury == win.maxy
  end

  def move_player
    if (@game.player.y - @offset[:y]) >= 12
      @offset[:y] = min(@game.player.y - 8, @game.map.height - @map_win.maxy)
      redraw_map
    end
    if @game.player.y == 8
      @offset[:y] = 0
      redraw_map
    end
    @map_win.setpos @game.player.y - @offset[:y], @game.player.x
    @map_win.addch '@'[0]
    @map_win.refresh
  end

  def hide_player
    @map_win.setpos @game.player.y - @offset[:y], @game.player.x - offset[:x]
    found_square = false
    @game.map.data['squares'].each do |square|
      if square['x'] == @game.player.x && square['y'] == @game.player.y
        found_square = true
        @map_win.addch items_symbol(square)
      end
    end
    @map_win.addch '.'[0] unless found_square
    @map_win.refresh
  end

  def draw_items(stack)
    @map_win.setpos stack['y'] - @offset[:y], stack['x'] - @offset[:x]
    @map_win.addch items_symbol(stack)
  end

  def items_symbol(square)
    @game.item_classes[square['items'].first].symbol[0]
  end
end
