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

describe Inventory do
  before(:each) do
    @inventory = Inventory.new
  end

  it "should be enumerable items container" do
    @inventory.collect{|item| item}.should == []
    @inventory << 'short sword' << 'leather armor'

    @inventory.invoke(:to_s).should == ['short sword', 'leather armor']
    @inventory.each do |item|
      item.should be_an_instance_of(Item)
    end
  end

  it "should accept not only item's name, but item also. and don't copy it" do
    item = Item.new('short sword')
    @inventory << item
    @inventory.items.first.object_id.should == item.object_id
  end

  it "should implement includes?" do
    @inventory.should_not include('short sword')
    @inventory << 'short sword'
    @inventory.should include('short sword')
  end
end

describe Inventory, "take" do
  before(:each) do
    @inventory = Inventory.new
  end

  it "should take item from inventory and return it" do
    @inventory << 'short sword' << 'leather armor'
    item = @inventory.take(1)
    item.should be_instance_of(Item)
    item.to_s.should == 'leather armor'
    @inventory.items.size.should == 1
  end

  it "should take nothing from inventory if index is negative" do
    @inventory << 'short sword' << 'leather armor'
    item = @inventory.take(-1).should be_nil
  end

  it "should take from inventory, filtered by slot" do
    ItemClass.load_all
    @inventory << 'short sword' << 'leather armor' << 'dagger'
    item = @inventory.take(1, :slot => 'weapon')
    item.to_s.should == 'dagger'
  end

  it "should take nothing, filtered by slot" do
    ItemClass.load_all
    @inventory << 'short sword' << 'leather armor' << 'dagger'
    @inventory.take(2, :slot => 'weapon').should be_nil
  end
end

describe Inventory, "filter" do
  it "should filter items by slot they can be equipped to" do
    ItemClass.load_all
    @inventory = Inventory.new
    @inventory << 'short sword' << 'leather armor' << 'dagger' << '15 darts' << 'short bow'
    @inventory.filter(:weapon).invoke(:to_s).should == ['short sword', 'dagger']
    @inventory.filter(:armor).invoke(:to_s).should == ['leather armor']
    @inventory.filter('ammunition').invoke(:to_s).should == ['15 darts']
    @inventory.filter('launcher').invoke(:to_s).should == ['short bow']
    @inventory.filter(nil).invoke(:to_s).should == ['short sword', 'leather armor', 'dagger', '15 darts', 'short bow']
  end
end
