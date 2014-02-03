class Map
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  trap_exit :actor_died

  attr_reader :id, :clients, :max_clients, :timer, :foods

  def handle_death(victim, killer=nil); end;

  def initialize(options={})
    @id = Celluloid.uuid
    @max_clients = options[:max_clients] || 2
    @parent = options[:parent]
    @clients = []
    @foods = []
  end

  def filled?
    clients.count >= @max_clients
  end

  def add_client(actor)
    info "#{self} Adding new client."
    @clients << actor
    actor.tournament = Actor.current
    link actor
  end
  alias_method :<<, :add_client

  def actor_died(actor, reason)
    info "#{self} Actor died"
    @clients.delete(actor)
    if @clients.empty?
      info "#{self} No more clients. Terminating Map."
      terminate
    end
  end

  #todo: fix nested loops
  def check_collisions
    @clients.each do |client|

      if client.blocks_self?
        handle_death client
      elsif (killer = @clients.detect { |c| c != client && c.blocks?(client) })

        if client.head == killer.head
          handle_tie client, killer
        else
          handle_death client, killer
        end
        
        break
      elsif (food = foods.detect { |f| f == client.head } )
        foods.delete(food)
        client.grow rand(2..8)
        after(3) { foods << Point.new(rand(49), rand(49)) }
      end
    end
  end

  def setup_placements
    @clients[0].move_to_point Point.new(4,24)
    @clients[0].direction = Direction::Right
    @clients[1].move_to_point Point.new(45,24)
    @clients[1].direction = Direction::Left
    @foods << Point.new(rand(49),rand(49))
  end

  def run
    setup_placements

    @timer = every(0.1) do
      futures = @clients.map { |c| c.future.step }
      futures.map &:value

      check_collisions

      positions = @clients.map(&:serialize) + @foods.map { |f| { 'type' => 'food', 'elements' => [f.to_a] } }
      @clients.each { |c| c.async.update_map(positions) }
    end
  end

  def to_s
    "[#{self.class.name} #{id}]"
  end
end
