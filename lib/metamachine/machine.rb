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
      Metamachine::Dispatch.new(self, name, obj, params).call
    end

    def run_transition(transition)
      runner.run(transition)
    end

    def calculate_state_to(state_from, event_name)
      transitions_map[event_name][state_from]
    end
  end
end
