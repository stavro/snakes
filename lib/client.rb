class Client < Snake
  attr_reader :socket

  trap_exit :actor_died

  def initialize(socket)
    info "Binding socket to client"

    @socket = socket
    listener = SocketListener.new(Actor.current, socket, :on_message)
    async.publish('tournament_request', Actor.current)
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
      dir = message["value"]
      @direction = Direction[dir] if valid_direction?(dir)
    end
  end

  def identify
    transmit Oj.dump({ 'type' => 'identify', 'value' => { 'id' => id } })
  end

  def update_map(map)
    transmit Oj.dump({ 'type' => 'map', 'value' => map })
  end

  def transmit(msg)
    @socket << msg
  rescue Reel::SocketError
    info "Time client disconnected"
    terminate
  end
end
