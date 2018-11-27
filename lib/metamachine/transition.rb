module Metamachine
  # Event that actually fired
  # It is a different object than `Definition::Event`
  class Transition
    attr_reader :event,
                :initial_state,
                :expected_state,
                :target,
                :params

    def initialize(
      event:,
      target:,
      machine:,
      params:
    )
      @event          = event.to_s
      @target         = target
      @machine        = machine
      @params         = params
      @initial_state  = target.send(machine.state_reader).to_s
      @expected_state = machine.expected_state_for(event, initial_state)
    end

    def run(&block)
      yield
    end
  end
end
