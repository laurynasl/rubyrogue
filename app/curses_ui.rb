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

    @sym_to_color = {
      :black => COLOR_BLACK,
      :green => COLOR_GREEN,
      :red => COLOR_RED,
      :cyan => COLOR_CYAN,
      :white => COLOR_WHITE,
      :magenta => COLOR_MAGENTA,
      :blue => COLOR_BLUE,
      :yellow => COLOR_YELLOW
    }
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

  def print_char(char)
    @map_win.attrset(Curses.color_pair(@sym_to_color[char.first]))
    @map_win.addch char.last
  end

  def redraw_map
    @game.map.calculate_fov
    @map_win.setpos 0, 0
    @map_win.maxy.times do |y|
      @map_win.maxx.times do |x|
        begin
          pos = [x + @offset[:x], y + @offset[:y]]
          #if @game.map.visible_at?(*pos)
            print_char @game.map.square_symbol_at(*pos)
          #else
            #print_char [:black, ' '[0]]
            #char = @game.map.memory[pos.last][pos.first] rescue nil
            #char ||= ' '[0]
            #print_char [:white, char]
          #end
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
      redraw_map
      move_player
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
        case dxdy = recognize_move(key)
        when Array
          @game.move_by(*dxdy)
        when ','[0]
          @game.pickup
        when 'i'[0]
          show_inventory scr
        when 'd'[0]
          drop_item scr
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
        when 'f'[0]
          target_and_shoot(scr)
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
      if slot = {'a'[0] => 'weapon', 'b'[0] => 'armor', 'c'[0] => 'ammunition'}[c]
        @game.player.equip(slot, select_item(scr))
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
    @map_win.addstr "A Weapon: #{@game.player.weapon}\n"
    @map_win.addstr "B Armor: #{@game.player.armor}\n"
    @map_win.addstr "C Ammunition: #{@game.player.ammunition}\n"
    @map_win.refresh
  end

  def select_item(scr)
    print_inventory
    scr.getch - 'a'[0]
  end

  def drop_item(scr)
    if item = @game.player.inventory.take(select_item(scr))
      @game.map.drop_items(@game.player.x, @game.player.y, [item])
    end
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

  def target_and_shoot(scr)
    monster = @game.map.find_nearest_visible_monster || @game.player
    square = [monster.x, monster.y]
    @map_win.setpos(*square.reverse)
    Curses.curs_set(1)
    @map_win.refresh

    while true do
      c = recognize_move(scr.getch)
      if c.is_a?(Array)
        square.add!(c)
        @map_win.setpos(*square.reverse)
        @map_win.refresh
      else
        case c
        when 'f'[0]:
          @game.output @game.player.ranged_attack(@game.map.find_monster(*square))
          break
        when 'z'[0]
          break
        end
      end
    end
    Curses.curs_set(0)
  end

  def recognize_move(key)
    case key
    when KEY_DOWN: [0, 1]
    when KEY_UP: [0, -1]
    when KEY_LEFT: [-1, 0]
    when KEY_RIGHT: [1, 0]
    else
      key
    end
  end
end
