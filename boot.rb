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
    puts 'requiring: ' + filename
    require filename
    eval name.to_s
  end
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

