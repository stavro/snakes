class Client < Snake
  attr_accessor :tournament
  attr_reader :socket, :id, :first_name, :last_name, :image_url, :wins, :losses

  trap_exit :actor_died

  def initialize(socket)
    info "Binding socket to client"

    @socket = socket
    listener = SocketListener.new(Actor.current, socket, :on_message)
    super
  end

  def actor_died(actor, reason)
    info "Terminating due to socket listener failure"
    terminate
  end

  def on_message(data)
    message = MultiJson.load data
    
    case message["type"]
    when "chat_message"
      msg = MultiJson.dump({
        'type' => 'chat_message',
        'id'   => id,
        'name' => first_name,
        'image_url' => image_url,
        'message' => message["value"]
      })

      tournament.clients.each { |c| c.transmit(msg) }
    when "identify"
      user = User.from_encrypted_id(message["value"])
      @first_name = user.first_name
      @last_name = user.last_name
      @image_url = user.image_url
      @wins = user.wins
      @losses = user.losses
      async.publish('tournament_request', Actor.current)
    when "direction"
      dir = message["value"]
      @direction = Direction[dir] if valid_direction?(dir)
    end
  end

  # def identify
  #   transmit MultiJson.dump({ 'type' => 'identify', 'value' => { 'id' => id } })
  # end

  def browser_hash
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      image_url: image_url,
      wins: wins,
      losses: losses
    }
  end

  def update_map(map)
    transmit MultiJson.dump({ 'type' => 'map', 'value' => map })
  end

  def broadcast_starting
    transmit MultiJson.dump({ 'type' => 'chat_message', id: 0, name: 'Server', message: 'A new game will begin in 5 seconds...'})
  end

  def broadcast_winner(winner)
    transmit MultiJson.dump({ 'type' => 'chat_message', id: 0, name: 'Server', message: "#{winner} is the winner!"})
  end

  def broadcast_participants(clients)
    transmit MultiJson.dump({ 'type' => 'participants', 'value' => clients.map(&:browser_hash) })
  end

  def add_loss
    user = User.find(@id)
    user.losses += 1
    user.save
  end

  def add_win
    user = User.find(@id)
    user.wins += 1
    user.save
  end

  def transmit(msg)
    @socket << msg
  rescue Reel::SocketError
    info "Time client disconnected"
    terminate
  end

end
