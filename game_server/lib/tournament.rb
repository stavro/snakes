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

    state :game_over do
      actor.timer.cancel
    end
  end

  def_delegator :machine, :transition
  def_delegator :machine, :state

  def initialize(options={})
    @machine = TournamentMachine.new
    super options
  end

  def start
    @clients.each { |c| c.broadcast_participants(@clients) }
    @clients.each { |c| c.server_message('A new game will begin in 5 seconds...') }
    after(5) { transition(:running) }
  end

  def broadcast_message(msg)
    @clients.each { |c| c.async.server_message(msg) }
  end

  def handle_tie(snake1, snake2)
    @clients.each { |c| c.async.broadcast_winner('TIE') }
    transition(:game_over)
  end

  def handle_death(victim, killer=nil)
    remaining = @clients - [victim]

    if remaining.count <= 0
      msg = "Hooray! Nobody wins."
      @clients.each { |c| c.async.server_message(msg) }
      transition(:game_over)
    elsif remaining.count == 1
      winner = remaining.first
      msg = "#{winner.first_name} is the winner!"
      @clients.each { |c| c.async.server_message(msg) }

      if winner.id != victim.id
        winner.add_win
        victim.add_loss
      end
      
      transition(:game_over)
    end
  end

end