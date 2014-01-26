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
  end

  def_delegator :machine, :transition
  def_delegator :machine, :state

  def initialize(options={})
    @machine = TournamentMachine.new
    super options
  end

  def start
    transition(:running)
  end

  def handle_killed(client)
    timer.cancel
    terminate
  end

end