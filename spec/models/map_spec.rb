require File.dirname(__FILE__) + '/../spec_helper'

describe Map, 'load' do
  it "should load map from file" do
    @map = Map.load(TESTMAP)
    @map.name.should == 'cave-1'
    @map.tiles.size.should == 21
    @map.tiles[1].should == "#...........................############\n"
    @map.width.should == 40
    @map.height.should == 21
    @map.squares.should_not be_nil
    @map.monsters.first.should be_instance_of(Monster)
  end
end

describe Map, 'find_square' do
  it "should find square" do
    @map = Map.load(TESTMAP)
    square = @map.find_square(1, 1) #.should == {'x' => 1, 'y' => 1, 'items' => ['short sword']}
    square.should be_instance_of(Square)
    square.x.should == 1
    square.y.should == 1
    square.items.first.name.should == 'short sword'
  end
end

describe Map, 'find_monster' do
  it "should find monster" do
    @map = Map.load(TESTMAP)
    monster = @map.find_monster(11, 1)
    monster.should be_instance_of(Monster)
    monster.x.should == 11
    monster.y.should == 1
    monster.monster_type.should == 'kobold'
  end
end

describe Map, "square_symbol_at" do
  before(:each) do
    @game = testgame
    @map = @game.map
  end

  it "should return background" do
    @map.square_symbol_at(3, 1).should be_char('.')
    @map.square_symbol_at(3, 2).should be_char('#')
    #@map.square_symbol_at(2, 1).should be_char('@')
    @map.square_symbol_at(2, 14).should be_char('(')
    @map.square_symbol_at(10, 1).should be_char('[')

    @map.find_square(10, 1).items = []
    @map.square_symbol_at(10, 1).should be_char('.')

    @map.square_symbol_at(26, 2).should be_char('>')
    @map.find_square(26, 2).stair['down'] = false
    @map.square_symbol_at(26, 2).should be_char('<')
  end

  it "should return space when square is outside of map" do
    @map.square_symbol_at(100, 1).should be_char(' ')
    @map.square_symbol_at(1, 100).should be_char(' ')
  end

  it "should display monster" do
    @map.square_symbol_at(11, 1).should be_char('k')
  end
end

describe Map, "passable_at?" do
  it "should return true when square is passable" do
    @game = testgame
    @map = @game.map

    @map.passable_at?(0, 0).should be_false # #
    @map.passable_at?(1, 1).should be_true  # .
    @map.passable_at?(11, 1).should be_false# k
  end
end

describe Map, "try_to_generate_monster" do
  it "should generate monster when one in 100 times" do
    kobold
    @game = testgame
    @map = @game.map

    @map.should_receive(:rand).with(100).and_return(0)
    @map.should_receive(:find_random_passable_square).and_return([1, 6])
    @kobold.x = nil
    @kobold.y = nil
    MonsterClass.should_receive(:generate).and_return(@kobold)

    @map.try_to_generate_monster

    @map.find_monster(1, 6).should == @kobold
  end

  it "should not generate monster when random returns nonzero" do
    @game = testgame
    @map = @game.map

    @map.should_receive(:rand).with(100).and_return(rand(99)+1)
    @map.should_not_receive(:find_random_passable_square)

    @map.try_to_generate_monster
  end
end

describe Map, "find_random_passable_square" do
  before(:each) do
    @game = testgame
    @map = @game.map
  end

  it "should find at first try" do
    @map.should_receive(:rand).with(40).and_return(1)
    @map.should_receive(:rand).with(21).and_return(6)

    @map.find_random_passable_square.should == [1, 6]
  end

  it "should find at third try" do
    @map.should_receive(:rand).and_return(34, 11, 22, 7, 23, 8)

    @map.find_random_passable_square.should == [23, 8]
  end
end
