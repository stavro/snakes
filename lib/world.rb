class World
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize
    subscribe('tournament_request', :tournament_request)
    @tournaments = []
    @open_tournament = Tournament.new
  end

  def tournament_request(topic, actor)
    exclusive do
      info "[World] Client requesting tournament..."
      @open_tournament << actor

      if @open_tournament.filled?
        @tournaments << @open_tournament
        @open_tournament.async.start
        @open_tournament = Tournament.new
      end

    end
  end

end
