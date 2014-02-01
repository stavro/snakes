class Client < Snake
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
    when "identify"
      key = ENV["ENCRYPTION_SECRET_KEY"] || 'secret'
      @id = Encryptor.decrypt(Base64.decode64(message["value"]), :key => key) rescue terminate
      user = User.find(@id)
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

  def broadcast_winner(winner)
    transmit MultiJson.dump({ 'type' => 'winner', 'value' => winner })
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
