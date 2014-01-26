class Tournament
  include Celluloid
  extend Forwardable

  class Machine
    include Celluloid::FSM
    default_state :waiting_for_participants

    state :waiting_for_participants, to: [:countdown] do

    end

    state :countdown,                to: [:game_over, :waiting_for_participants]
    state :game_over
  end

  attr_reader :machine, :map

  def_delegator :machine, :state
  def_delegator :machine, :transition


  def initialize(options={})
    @machine = Machine.new
    @map = Map.new
  end

  def add_client(client)

  end

  def enough_participants?
    true
  end

end