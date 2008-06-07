class BeChar
  def initialize(expected)
    @expected = expected
  end

  def matches?(target)
    @target = target
    target == @expected[0]
  end

  def failure_message
    "expected '#{@expected}', got '#{"".concat @target.to_i}'"
  end
end

def be_char(expected)
  BeChar.new(expected)
end
