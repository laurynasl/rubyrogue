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

class Inventory
  include Enumerable

  attr_accessor :items

  def initialize
    @items = []
  end

  def each
    for item in @items
      yield item
    end
  end

  def <<(item)
    @items << (item.is_a?(Item) ? item : Item.new(item))
    self
  end

  def include?(item_name)
    for item in @items
      return true if item.name == item_name
    end
    false
  end

  def take(i)
    if i >= 0
      @items.delete_at(i)
    end
  end
end
