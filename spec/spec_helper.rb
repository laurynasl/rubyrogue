require File.expand_path(File.dirname(__FILE__) + "/../boot")
require 'spec'
require 'lib/rspec_matchers'

Spec::Runner.configure do |config|
end

def testgame
  Game.new('games/test/game.yaml')
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
