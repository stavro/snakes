module Direction
  Up    = Point.new(0,-1).freeze
  Right = Point.new(1,0).freeze
  Down  = Point.new(0,1).freeze
  Left  = Point.new(-1,0).freeze

  def self.[](str)
    const_get str.capitalize
  end

  def self.valid?(str)
    const_defined? str.capitalize
  end
end
