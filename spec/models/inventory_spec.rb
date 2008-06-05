require File.dirname(__FILE__) + '/../spec_helper'

describe Inventory do
  before(:each) do
    @inventory = Inventory.new
  end

  it "should be enumerable items container" do
    @inventory.collect{|item| item}.should == []
    @inventory << 'short sword' << 'leather armor'

    @inventory.collect{|item| item.to_s}.should == ['short sword', 'leather armor']
    @inventory.each do |item|
      item.should be_an_instance_of(Item)
    end
  end

  it "should implement includes?" do
    @inventory.should_not include('short sword')
    @inventory << 'short sword'
    @inventory.should include('short sword')
  end
end
