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

class ItemClass < Constructable
  attr_accessor :damage, :accuracy, :symbol, :skill, :armor, :evasion, :damage_type
  #ranged
  attr_accessor :launches, :ranged_damage, :ammunition, :launcher_damage
  #generation
  attr_accessor :chance, :count

  class << self
    include MassLoadable
  end


  def self.load_all
    load_all_from 'data/items.yaml'
  end
end
