require File.expand_path(File.dirname(__FILE__) + "/../boot")
require 'spec'

Spec::Runner.configure do |config|
end

def testgame
  Game.new('maps/testgame.yaml')
end
