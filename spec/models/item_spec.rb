require File.dirname(__FILE__) + '/../spec_helper'

describe Item do
  it "should be convert to string" do
    item = Item.new('short sword')
    item.to_s.should == 'short sword'
  end
end

describe Item, "klass" do
  it "should return ItemClass object with same name" do
    item = Item.new('short sword')
    ItemClass.load_all
    item.klass.should == ItemClass.all['short sword']
  end
end
