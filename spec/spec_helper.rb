require File.expand_path(File.dirname(__FILE__) + "/../boot")
require 'spec'

Spec::Runner.configure do |config|
end

def testgame
  Game.new('games/test/game.yaml')
end

TESTGAME = 'games/test/game.yaml'
TESTMAP = 'games/test/testmap.yaml'
