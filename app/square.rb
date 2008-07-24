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

class Square < Constructable
  attr_accessor :x, :y, :items, :stair

  def initialize(attributes)
    super
    @items ||= []
  end

  def items=(data)
    @items = data.collect do |item_name|
      Item.new item_name
    end
  end

  def item_names
    items.collect{|item| item.name}
  end

  def look
    if stair
      "you see here: " + {true => "downstairs", false => "upstairs"}[stair['down']]
    else
      "you see here: " + items.join(', ')
    end
  end

  def empty?
    items.empty? && !stair
  end
end
