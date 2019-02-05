module Metamachine
  class Transition
    attr_reader :event,
                :state_from,
                :state_to,
                :target,
                :params

    def initialize(
      event:,
      target:,
      machine:,
      params:
    )
      @event      = event.to_s
      @target     = target
      @machine    = machine
      @params     = params
      @state_from = current_target_state
      @state_to   = machine.expected_state_for(event, state_from)
    end

    def run(&_block)
      yield
    end

    def validate_result!
      raise NotExpectedResultState if current_target_state != state_to
    end

    private

    attr_reader :machine

    def current_target_state
      target.send(machine.state_reader).to_s
    end
  end
end
