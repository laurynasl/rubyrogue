#!/usr/bin/env ruby
require 'test/unit'
require 'src/item_class.rb'
require File.join(File.dirname(__FILE__), '../test_helper.rb')

class TC_ItemClass < Test::Unit::TestCase
  def setup
    @item = ItemClass.new 'short sword' => {
      'damage' => 5,
      'accuracy' => 0,
      'skills' => ['slashing', 'sword']
    }
  end

  # def teardown
  # end
#
#   def test_fail
#     assert(false, 'Assertion was false.')
#   end

  def test_it

  end
end
