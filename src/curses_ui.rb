require 'curses'

include Curses

class CursesUI
  MESS_HEIGHT = 6
  ATT_WIDTH = 18
  def initialize(debug=false)
    # Init the action map
    init_actions

    # Init game
    puts $*.inspect
    @game = Game.new($*[0])

    # Draws the windows
    draw_windows
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
    @game.output 'maxx: ' + @map_win.maxx.to_s
    @map_win.setpos 0, 0
    @map_win.maxy.times do |y|
      @map_win.maxx.times do |x|
        begin
          @map_win.addch @game.map.tiles[y][x]
        rescue
#           @game.output('Error: ' + $!.to_s)
        end
      end
    end
  end

  ##
  # Does the game loop (including key reading and dispatching)
  #
  def game_loop
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
        @game.output keyname(key) || key
      rescue
        #@game.output $!.to_s + key.to_s
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

    # Special handling for arrow keys
    dirs = {KEY_UP => :up,
      KEY_LEFT => :left,
      KEY_RIGHT => :right,
      KEY_DOWN => :down}

    dirs.each do |key, dir|
      # Specify it here if arrow
      # keys need to be given another meaning
      #@@actions[key] = [ChatAction.new(dir),
      #                  MoveAction.new(dir)]
    end
  end

  ##
  # Shows the text in the message window
  #
  def draw_message(win, m)
    win << m + "\n"
    win.scroll if win.cury == win.maxy
  end


end
