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

$: << 'app'
require 'rubygems'
#require 'active_support'
#require 'curses_ui'
require 'getoptlong'
require 'rdoc/ri/ri_paths'
require 'rdoc/usage'
require 'lib/fov/ruby_fov'
require 'app/array'

opts = GetoptLong.new([ '--help', '-h', GetoptLong::NO_ARGUMENT ], [ '--debug', '-d', GetoptLong::OPTIONAL_ARGUMENT ])

class String
  def underscore
    self.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

class Module
  def const_missing(name)
    filename = name.to_s.underscore
    log 'requiring: ' + filename
    require filename
    eval name.to_s
  end
end

module Enumerable
  def invoke(method)
    collect{|i| i.send(method)}
  end
end

def log(text)
  $logfile ||= File.new('log/stdout.log', 'a')
  $logfile << text.to_s + "\n"
  $logfile.flush
end

def min(a, b)
  a < b ? a : b
end

def max(a, b)
  a > b ? a : b
end

debug = false
opts.each do |opt, arg|
  case opt
  when '--help'
    RDoc::usage
  when '--debug'
    if arg == ''
      debug = 1
    else
      debug = arg.to_i
    end
 end
end

# Need to log?
if debug
  require "logger"
  $log = Logger.new('logs/debug', 'daily')

  case debug
  when 0
    $log.level = Logger::DEBUG
  when 1
    $log.level = Logger::INFO
  when 2
    $log.level = Logger::WARN
  when 3
    $log.level = Logger::ERROR
  when 4
    $log.level = Logger::FATAL
  else RDoc::usage
  end
end

