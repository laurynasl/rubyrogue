#!/usr/bin/ruby

#
# == Synopsis
# launch.rb: It launches a game of RubyRogue, with Curses interface.
#
# == Usage
# ./launch.rb [OPTION]
#
# -h, --help:
#     Shows this help
# -d, --debug [level]
#     Launches the game in debug mode, creating a 'debug' file in 'logs/'
#     If a level is not specified, level 1 is used.
#     Levels go from 0 to 4, where 0 means 'log everything'
#     and 4 'log just fatal errors'

require 'boot.rb'

def puts(text)
  $logfile ||= File.new('log/stdout.log', 'a')
  $logfile << text.to_s + "\n"
end


CursesUI.new().game_loop
