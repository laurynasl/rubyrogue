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

module MassLoadable
  def all
    eval "@@#{self.name}all"
  end

  def all=(value)
    eval "@@#{self.name}all = value"
  end

  def load_all_from(filename)
    f = File.open(filename)
    items_data = YAML::load(f)
    self.all = {}
    items_data.each do |key, value|
      all[key] = new(value)
    end
    f.close
  end
end
