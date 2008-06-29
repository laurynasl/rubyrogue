class BeChar
  def initialize(expected)
    @expected = expected
  end

  def matches?(target)
    @target = target
    target == @expected
  end

  def failure_message
    "expected #{@expected.first} '#{"".concat @expected.last}', got #{@target.first} '#{"".concat @target.last}'"
  end
end

def be_char(color, char)
  BeChar.new([color, char[0]])
end
