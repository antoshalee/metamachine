module Metamachine
  class Dispatch
    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(machine, event, target, params)
      @machine = machine
      @event   = event
      @target  = target
      @params  = params
    end

    def call
      @state_from = current_state
      @state_to = machine.calculate_state_to(state_from, event)

      build_transition.tap do |transition|
        with_contract do
          machine.run_transition(transition)
        end
      end
    end

    private

    attr_reader :machine,
                :target,
                :event,
                :params,
                :state_from,
                :state_to

    def with_contract
      validate_transition_possibility!

      yield

      validate_state_to!
    end

    def validate_transition_possibility!
      # Transition is impossible if we don't detect result state
      raise InvalidTransitionInitialState if state_to.nil?
    end

    def validate_state_to!
      raise NotExpectedResultState if current_state != state_to
    end

    def current_state
      target.send(machine.state_reader)
    end

    def build_transition
      Metamachine::Transition.new(
        machine: machine,
        event: event,
        target: target,
        params: params,
        state_from: state_from,
        state_to: state_to
      )
    end
  end
end
