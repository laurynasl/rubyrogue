require File.dirname(__FILE__) + '/../spec_helper'

describe Item do
  it "should be convert to string" do
    item = Item.new('short sword')
    item.to_s.should == 'short sword'
  end
end
