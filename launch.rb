#!/usr/bin/env ruby

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


CursesUI.new($*[0]).game_loop
