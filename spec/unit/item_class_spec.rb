require File.dirname(__FILE__) + '/../spec_helper'

describe ItemClass do
  it "should create sword" do
    @item = ItemClass.new 'short sword' => {
      'damage' => 5,
      'accuracy' => 0,
      'skills' => ['slashing', 'sword']
    }
  end
end
