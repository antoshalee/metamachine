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
      params:,
      state_from:,
      state_to:
    )
      @event      = event.to_s
      @target     = target
      @machine    = machine
      @params     = params
      @state_from = state_from
      @state_to   = state_to
    end

    def validate_result!
      raise NotExpectedResultState if machine.state_of(target) != state_to
    end

    private

    attr_reader :machine
  end
end
