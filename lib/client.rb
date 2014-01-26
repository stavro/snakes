class Client < Snake
  attr_reader :socket

  trap_exit :actor_died

  def initialize(socket)
    info "Binding socket to client"

    @socket = socket
    listener = SocketListener.new(Actor.current, socket, :on_message)

    subscribe('update_snake_positions', :update_snake_positions)
    async.publish('new_client', Actor.current)
    async.identify
    super
  end

  def actor_died(actor, reason)
    info "Terminating due to socket listener failure"
    terminate
  end

  def on_message(data)
    message = Oj.load data

    case message["type"]
    when "direction"
      direction = message["value"]
      @direction = Direction[direction] if valid_direction?(direction)
    end
  end

  def identify
    transmit Oj.dump({ 'type' => 'identify', 'value' => { 'id' => id } })
  end

  def update_snake_positions(topic, snakes)
    transmit Oj.dump({ 'type' => 'snakes', 'value' => snakes })
  end

  def transmit(msg)
    @socket << msg
  rescue Reel::SocketError
    info "Time client disconnected"
    terminate
  end
end
