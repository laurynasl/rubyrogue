require File.dirname(__FILE__) + '/../spec_helper'

describe MonsterClass do
  it "should be constructable" do
    klass = MonsterClass.new({
      'strength' => 6,
      'dexterity' => 7,
      'perception' => 5,
      'health' => 5,
      'intelligence' => 6,
      'danger' => 1
    })
    klass.strength.should == 6
  end

  it "should be mass loadable" do
    MonsterClass.load_all
    MonsterClass.all['kobold'].should_not be_nil
  end
end
