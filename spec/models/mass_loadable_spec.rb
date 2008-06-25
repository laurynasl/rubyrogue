require File.dirname(__FILE__) + '/../spec_helper'

describe MassLoadable do
  before(:each) do
    @klass = Class.new(Constructable)
    @klass.class_eval "class << self; include MassLoadable; end"
    @klass.class_eval('attr_accessor :damage, :accuracy, :symbol, :skill, :armor, :evasion, :damage_type')
  end

  it "should create short sword" do
    @item = @klass.new({
      'damage' => 5,
      'accuracy' => 0,
      'symbol' => '(',
      'skill' => 'sword',
      'damage_type' => 'slashing'
    })
    @item.damage.should == 5
    @item.accuracy.should == 0
    @item.symbol.should == '('
    @item.skill.should == 'sword'
  end

  it "should create leather armor" do
    @item = @klass.new({
      'armor' => 3,
      'evasion' => 1,
      'symbol' => '['
    })
  end

  it "should load all item classes" do
    @klass.load_all_from('data/items.yaml')

    short_sword = @klass.all['short sword']
    short_sword.class.should == @klass
  end
end
