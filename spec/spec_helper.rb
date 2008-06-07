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
