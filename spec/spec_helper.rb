require File.expand_path(File.dirname(__FILE__) + "/../boot")
require 'spec'
require 'lib/rspec_matchers'

Spec::Runner.configure do |config|
end

def testgame
  ItemClass.load_all
  MonsterClass.load_all
  game = Game.new('games/test/game.yaml')
  @ui = mock('ui')
  game.ui = @ui
  game
end

TESTGAME = 'games/test/game.yaml'
TESTMAP = 'games/test/cave-1.yaml'

def it_should_have_fields(object_name, *attributes)
  attributes.each do |attribute|
    it "should have #{attribute}" do
      object = instance_variable_get("@#{object_name}")
      object.send("#{attribute}=", nil)
      lambda {
        object.validate!
      }.should raise_error(RuntimeError, "#{attribute} is required!")
    end
  end
end

def orc(options = {})
  @orc = Monster.new({
    'hp' => 9,
    'maxhp' => 9,
    'health' => 9,
    'dexterity' => 9,
    'perception' => 5,
    'monster_type' => 'orc'
  }.merge(options))
end

def kobold(options = {})
  @kobold = Monster.new({
    'x' => 10,
    'y' => 1,
    'hp' => 4,
    'maxhp' => 4,
    'health' => 4,
    'dexterity' => 7,
    'perception' => 7,
    'monster_type' => 'kobold'
  }.merge(options))
end
