class Map
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  trap_exit :actor_died

  STAGE_HEIGHT = 49
  STAGE_WIDTH  = 49

  attr_reader :clients

  def initialize
    subscribe('new_client', :new_client)
    @clients = []
    super

    async.run
  end

  def new_client(topic, actor)
    info "Adding client..."
    @clients << actor
    link actor
  end

  def actor_died(actor, reason)
    info "Actor died"
    @clients.delete(actor)
  end

  def check_collisions
    killed = @clients.select do |client|
      client.blocks_self? ||
      @clients.any? do |c|
        c != client && c.blocks?(client) && c.add_kill
      end
    end

    killed.each { |c| c.async.reset }
  end

  def run
    every(0.05) do
      futures = @clients.map { |c| c.future.step }
      futures.map &:value

      check_collisions

      publish('update_snake_positions', @clients.map(&:serialize) )
    end
  end
end
