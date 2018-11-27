module Metamachine
  module Definition
    class Machine
      attr_reader :states,
                  :events,
                  :state_reader

      def initialize(klass, state_reader, &block)
        @klass = klass
        @state_reader = state_reader.to_s
        @states = []
        @events = {}

        instance_eval(&block) if block_given?
      end

      def state(*states)
        @states += states.map(&:to_s)
      end

      def event(name, &block)
        name = name.to_s

        evt = Definition::Event.new(name, &block)

        validate_event_transitions(evt)

        @events[name] = evt

        Monkeypatcher.call(@klass, name)
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
