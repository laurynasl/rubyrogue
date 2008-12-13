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
require 'rdoc/ri/ri_paths'
require 'rdoc/usage'
require 'lib/fov/ruby_fov'
require 'app/array'

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
  alias :const_missing_before_rubyrogue :const_missing
  def const_missing(name)
    filename = 'app/' + name.to_s.underscore + '.rb'
    if File.exist?(filename)
      log 'requiring: ' + filename
      require filename
      eval name.to_s
    else
      const_missing_before_rubyrogue(name)
    end
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
