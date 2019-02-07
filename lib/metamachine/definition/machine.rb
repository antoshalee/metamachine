module Metamachine
  module Definition
    class Machine
      attr_reader :states,
                  :events,
                  :state_reader,
                  :runner

      def initialize(klass, state_reader, &block)
        @klass = klass
        @state_reader = state_reader.to_s
        @states = []
        @events = {}

        instance_eval(&block) if block_given?
      end

      # DSL: states definition
      def state(*states)
        @states += states.map(&:to_s)
      end

      # DSL: event definition
      def event(name, &block)
        name = name.to_s

        evt = Definition::Event.new(name, &block)

        validate_event_transitions(evt)

        @events[name] = evt

        Monkeypatcher.call(@klass, name)
      end

      # DSL: runner definition
      def run(&block)
        @runner = Metamachine::Runner.new(self, &block)
      end

      def build_transition(event, target, params)
        Metamachine::Transition.new(
          machine: self,
          event: event,
          target: target,
          params: params
        )
      end

      def run_transition(transition)
        runner.run(transition)
      end

      def expected_state_for(event, state)
        events[event].transitions[state] || raise(InvalidTransitionInitialState)
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
end
