module Metamachine
  class Machine
    attr_reader :state_reader,
                :states,
                :transitions_map,
                :runner

    def initialize(&dsl)
      @states = []
      @transitions_map = {}

      DSL::Root.new(machine: self).call(&dsl)
    end

    def dispatch_event(name, obj, params)
      Metamachine::Dispatch.call(self, name, obj, params)
    end

    def run_transition(transition)
      runner.run(transition)
    end

    def calculate_state_to(state_from, event_name)
      transitions_map[event_name][state_from]
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
