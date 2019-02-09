module Metamachine
  class Machine
    attr_accessor :state_reader

    attr_reader :target_class,
                :states,
                :events,
                :runner

    def initialize(target_class, state_reader)
      @target_class = target_class

      if !state_reader.is_a?(Symbol) && !state_reader.is_a?(String)
        raise ArgumentError, 'state reader must be a String or a Symbol'
      end

      @state_reader = state_reader
      @states = []
      @events = {}
    end

    def register!
      Metamachine::Registry.add(self)
    end

    def build_transition(event, target, params)
      Metamachine::Transition.new(
        machine: self,
        event: event,
        target: target,
        params: params
      )
    end

    def register_event(name)
      @events[name.to_s] = {}

      # TODO
      # validate_event_transitions(evt)
      Metamachine::Monkeypatcher.call(target_class, name)
    end

    def register_transition(event, from, to)
      Array(from).each { |f| events[event][f.to_s] = to.to_s }
    end

    def register_runner(&block)
      @runner = Metamachine::Runner.new(&block)
    end

    def run_transition(transition)
      runner.run(transition)
    end

    def expected_state_for(event, state)
      events[event][state] || raise(InvalidTransitionInitialState)
    end

    def state_of(target)
      target.send(state_reader)
    end

    private

    def validate_event_transitions(evt)
      unknown_states =
        (evt.transitions.keys + evt.transitions.values).uniq - states

      return if unknown_states.empty?

      raise Definition::UnknownState,
            "Uknown state: #{unknown_states.join(', ')}. Define them in advance of events"
    end
  end
end
