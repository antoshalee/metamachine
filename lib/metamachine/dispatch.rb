module Metamachine
  # Handler of events
  # Builds transition and contract
  # Runs transition runner in the context of contract
  class Dispatch
    def initialize(machine, event_name, target, params)
      @machine    = machine
      @event_name = event_name
      @target     = target
      @params     = params
    end

    def call
      build_transition.tap do |transition|
        transition.contract!(transition.target) do
          machine.run_transition(transition)
        end
      end
    end

    private

    attr_reader :machine,
                :target,
                :event_name,
                :params

    def build_transition
      Transition.new(
        event_name: event_name,
        target: target,
        params: params,
        contract: build_contract
      )
    end

    def build_contract
      state_from = target.send(machine.state_reader)
      state_to = machine.calculate_state_to(state_from, event_name)

      raise InvalidTransitionInitialState if state_to.nil?

      StateContract.new(
        state_from:   state_from,
        state_to:     state_to,
        state_reader: machine.state_reader
      )
    end
  end
end
