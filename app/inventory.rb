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
  @@slots_map = {:weapon => :damage, :armor => :armor, :ammunition => :ranged_damage, :launcher => :launcher_damage}

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
    item = (item.is_a?(Item) ? item : Item.new(item))
    if found_item = @items.find {|i| i.name == item.name}
      found_item.count += item.count
    else
      @items << item
    end
    self
  end

  def include?(item_name)
    for item in @items
      return true if item.name == item_name
    end
    false
  end

  def take(i, options = {})
    if options[:slot]
      attribute = @@slots_map[options[:slot].to_sym]
      matched_count = 0
      @items.each_with_index do |item, index|
        if item.klass.send(attribute)
          matched_count += 1
          if matched_count == (i+1)
            return @items.delete_at(index)
          end
        end
      end
      nil
    else
      if i >= 0
        @items.delete_at(i)
      end
    end
  end

  def filter(slot)
    if slot
      attribute = @@slots_map[slot.to_sym]
      @items.find_all {|item| item.klass.send(attribute)}
    else
      @items
    end
  end
end
