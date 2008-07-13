class Array
  def add!(other)
    raise 'sizes must be equal' if size != other.size
    size.times do |i|
      self[i] += other[i]
    end
    self
  end
end
