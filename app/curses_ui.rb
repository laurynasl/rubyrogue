require 'curses'

Dir['app/*.rb'].each do |f|
  require f
end

include Curses

class CursesUI
  attr_accessor :game, :offset
  MESS_HEIGHT = 6
  ATT_WIDTH = 18
  def initialize(filename = nil)
    # Init the action map
    init_actions
    @offset = {:x => 0, :y => 0}

    if /savegames\/.+\.yaml/ === filename
      @game = Game.restore(filename)
    else
      # Init game
      @game = Game.new(filename)
    end
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
      move_player
    end

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
    draw_attributes
  end

  def repaint_square(x, y)
    @map_win.setpos(y- @offset[:y], x - @offset[:x])
    @map_win.addch(@game.map.square_symbol_at(x, y))
    @map_win.refresh
  end

  def redraw_map
    @game.output @map_win.maxx.to_s + 'x' + @map_win.maxy.to_s
    @map_win.setpos 0, 0
    @map_win.maxy.times do |y|
      @map_win.maxx.times do |x|
        begin
          @map_win.addch @game.map.square_symbol_at(x + @offset[:x], y + @offset[:y])
        #rescue
          #$error_id ||= 0
          #$error_id += 1
          #msg = "#{$error_id} Error: " + $!.to_s
          #puts msg
          #@game.output(msg)
        end
      end
    end
    @map_win.refresh
  end

  ##
  # Does the game loop (including key reading and dispatching)
  #
  def game_loop
    # Draws the windows
    draw_windows

    # Loop controller
    playing = true

    # Real game loop
    while playing do
      # First, we show all queued messages
      messages  = ''
      while m = @game.read_message do
        messages << m << '. '
      end
      draw_message(@mess_win, messages) unless messages.empty?
      @mess_win.refresh

      playing = handle_input(@scr)

      # Launches the game logics
      @game.iterate
      draw_attributes
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
        when ','[0]
          @game.pickup
        when 'i'[0]
          show_inventory scr
        when 'e'[0]
          manage_equipment scr
        when '>'[0]
          game.go_stairs(true)
        when '<'[0]
          game.go_stairs(false)
        when 'c'[0]
          game.output("%s is at %d, %d" % [game.player.fullname, game.player.x, game.player.y])
        when 'S'[0]
          game.save(game.player.fullname)
          keep_playing = false
        else
          @game.output((key.is_a?(Fixnum) ? keyname(key) : key.to_s) || key.to_s)
        end
      #rescue
        #puts $!.to_s
        #puts $!.backtrace.join("\n")
        #@game.output $!.to_s
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
    if (@game.player.y - @offset[:y]) >= (@map_win.maxy - 4)
      @offset[:y] = min(@game.player.y - 8, @game.map.height - @map_win.maxy)
      redraw_map
    end
    if @game.player.y == 8
      @offset[:y] = 0
      redraw_map
    end
    @map_win.setpos @game.player.y - @offset[:y], @game.player.x
    @map_win.addch '@'[0]
    if square = @game.map.find_square(@game.player.x, @game.player.y)
      @game.output square.look # + square.item_names.join(', ')
    end
    @map_win.refresh
  end

  def hide_player
    @map_win.setpos @game.player.y - @offset[:y], @game.player.x - offset[:x]
    @map_win.addch @game.map.square_symbol_at(@game.player.x, @game.player.y)
    @map_win.refresh
  end

  def in_viewport?(square)
    x = square.x
    y = square.y
    return false if x >= @map_win.maxx + @offset[:x]
    return false if y >= @map_win.maxy + @offset[:y]
    return false if x < @offset[:x]
    return false if y < @offset[:y]
    true
  end

  def show_inventory(scr)
    print_inventory
    while scr.getch != 'z'[0]
    end
    redraw_map
    move_player
    @map_win.refresh
  end

  def print_inventory
    @map_win.setpos 0, 0
    @map_win.clear
    @map_win.addstr "Inventory\n"
    @map_win.addstr "Press 'z' to exit\n\n"
    @game.player.inventory.each_with_index do |item, i|
      @map_win.addstr "".concat('A'[0] + i) + ' ' + item.to_s + "\n"
    end
    @map_win.refresh
  end

  def manage_equipment(scr)
    print_equipment
    while (c = scr.getch) != 'z'[0]
      if c == 'w'[0]
        @game.player.equip('weapon', select_item(scr))
      end
      print_equipment
    end
    redraw_map
    move_player
    @map_win.refresh
  end

  def print_equipment
    @map_win.setpos 0, 0
    @map_win.clear
    @map_win.addstr "Equipment\n"
    @map_win.addstr "Press 'z' to exit\n\n"
    @map_win.addstr "W Weapon: #{@game.player.weapon}\n"
    @map_win.addstr "A Armor: \n"
    @map_win.refresh
  end

  def select_item(scr)
    print_inventory
    scr.getch - 'a'[0]
  end

  def draw_attributes
    @att_win.clear
    @att_win.setpos 0, 0
    @att_win.addstr("Health %d/%d\n" % [game.player.hp, game.player.maxhp])
    @att_win.addstr("Dexterity %d\n" % game.player.dexterity)
    @att_win.addstr("Perception %d\n" % game.player.perception)
    @att_win.addstr("Health %d\n" % game.player.health)
    @att_win.refresh
  end
end
