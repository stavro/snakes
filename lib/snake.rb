class Snake
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger
  extend Forwardable

  attr_accessor :direction
  attr_reader :id, :length, :elements, :last_movement_direction

  def_delegator :@last_movement_direction, :opposite, :opposite_direction

  def valid_direction?(d)
    dir = Direction[d]
    dir && dir != opposite_direction
  end

  def initialize(options = {})
    @id = SecureRandom.uuid
    reset
  end

  def reset
    @length = 6
    @direction = Direction::Right
    @last_movement_direction = @direction
    @elements = [Point.new(-1,-1)]*@length
  end

  def head
    @elements[@length - 1]
  end

  def blocks_self?
    h = head
    0.upto(length - 2).any? { |i| h == elements[i] }
  end

  def blocks?(target)
    target_head = target.head
    elements.any? { |el| el == target_head }
  end

  def grow(count=1)
    @length += count
    count.times { @elements.unshift Point.new(-1, -1) }
  end

  def step
    @last_movement_direction = direction
    move_head
    elements.shift #remove tail
  end

  def move_head
    new_head = head + direction
    elements.push( new_head )

    new_head.x = 49 if new_head.x < 0
    new_head.x = 0 if new_head.x > 49

    new_head.y = 49 if new_head.y < 0
    new_head.y = 0 if new_head.y > 49
  end

  def move_to_point(p, head_only=false)
    if head_only
      @elements[@length - 1] = p.dup
    else
      @elements = [p.dup]*@length
    end
  end

  def serialize
    {
      "type" => "snake",
      "id" => id,
      "length" => length,
      "elements" => elements.map(&:to_a)
    }
  end

end