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
