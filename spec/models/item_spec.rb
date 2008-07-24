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

require File.dirname(__FILE__) + '/../spec_helper'

describe Item do
  it "should be convertable to string" do
    item = Item.new('short sword')
    item.to_s.should == 'short sword'
  end

  it "should have optional count" do
    item = Item.new('dart')
    item.count = 3
    item.count.should == 3
  end

  it "should parse item's count" do
    item = Item.new('22 darts')
    item.name.should == 'dart'
    item.count.should == 22
    item.to_s.should == '22 darts'
  end

end

describe Item, "klass" do
  it "should return ItemClass object with same name" do
    item = Item.new('short sword')
    ItemClass.load_all
    item.klass.should == ItemClass.all['short sword']
  end
end
