class Point < Struct.new(:x, :y)
  def +(p2)
    self.class.new(x+p2.x, y+p2.y)
  end

  def *(int)
    self.class.new(x*int, y*int)
  end

  def opposite
    self * -1
  end
end
