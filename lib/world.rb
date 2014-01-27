class World
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  trap_exit :actor_died

  def initialize
    subscribe('tournament_request', :tournament_request)
    @tournaments = []
    create_new_tournament
  end

  def tournament_request(topic, actor)
    exclusive do
      info "[World] Client requesting tournament..."
      @open_tournament << actor

      if @open_tournament.filled?
        @tournaments << @open_tournament
        @open_tournament.async.start
        create_new_tournament
      end
    end
  end

  def actor_died(actor, reason)
    exclusive do
      info "[World] Actor died"
      if actor == @open_tournament
        create_new_tournament
      else
        @tournaments.delete actor
      end
    end
  end

  def create_new_tournament
    @open_tournament = Tournament.new
    link @open_tournament
  end

end
