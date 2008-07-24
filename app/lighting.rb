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

class Lighting < Constructable
  attr_accessor :map, :tiles, :memorize

  def initialize(options)
    super
    @tiles ||= []
  end

  def calculate_fov
    RubyFov.calculate(self, map.game.player.x, map.game.player.y, map.game.player.perception)
  end

  def [](i)
    tiles[i]
  end

  def apply_lighting(x, y)
    @tiles[y * map.width + x] = true
    @map.apply_lighting(x, y) if memorize
  end

  def opaque_at?(x, y)
    @map.opaque_at?(x, y)
  end
end
