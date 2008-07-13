require File.dirname(__FILE__) + '/../spec_helper'

describe Array, "add!" do
  it "should add other array to first" do
    a = [1, 2]
    a.add!([12, 14]).should == [13, 16]
    a.should == [13, 16]
  end
end
