class Tournament < Map
  extend Forwardable

  attr_reader :machine, :timer

  class TournamentMachine
    include Celluloid::FSM

    default_state :waiting

    state :waiting, :to => :running
    state :running, :to => :game_over do
      actor.async.run
    end

    state :game_over
  end

  def_delegator :machine, :transition
  def_delegator :machine, :state

  def initialize(options={})
    @machine = TournamentMachine.new
    super options
  end

  def start
    @clients.each { |c| c.broadcast_participants(@clients) }
    transition(:running)
  end

  def handle_tie(snake1, snake2)
    @clients.each { |c| c.broadcast_winner('TIE') }
    async.terminate
    transition(:game_over)
  end

  def handle_death(victim, killer=nil)
    remaining = @clients - [victim]

    if remaining.count == 1
      winner = remaining.first
      @clients.each { |c| c.broadcast_winner("Winner: #{winner.first_name}") }

      if winner.id != victim.id
        winner.add_win
        victim.add_loss
      end
      
      transition(:game_over)
      async.terminate
    end
  end

end