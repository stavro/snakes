class SocketListener
  include Celluloid
  attr_reader :actor, :socket, :callback

  def initialize(actor, socket, callback)
    @actor    = actor
    @socket   = socket
    @callback = callback

    actor.link Actor.current
    async.listen
  end

  def listen
    loop { actor.async.send(callback, socket.read) }
  rescue
  ensure
    terminate
  end
end