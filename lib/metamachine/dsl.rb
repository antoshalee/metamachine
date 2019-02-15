# frozen_string_literal: true

module Metamachine
  # Extend your class with this module in order to
  # allow metamachine DSL:
  #
  #   class YourClass
  #     extend Metamachine::DSL
  #
  #     metamachine do
  #       ..
  #     end
  #  end
  module DSL
    # Base class for all DSL nodes
    # Node reflects method execution and it's class name reflects a chain:
    #
    # E.g. `Metamachine::Event::Transition` is a class for a DSL node
    # which actually executes `metamachine.event.transition` chain
    class Base
      attr_reader :context,
                  :machine

      # context is a parent node except for the root `Metamachine` node
      # for which context is a host class
      def initialize(context, machine = nil)
        @context = context
        @machine = machine
      end

      def method_missing(method, *args, &block)
        klass = child_node_class(method)

        return super unless klass

        klass.new(self, machine).call(*args, &block)
      end

      def respond_to_missing?(method_name, _)
        !child_node_class(method_name).nil? || super
      end

      private

      KNOWN_NODES = {
        'state_reader' => 'StateReader',
        'state'        => 'State',
        'event'        => 'Event',
        'transition'   => 'Transition',
        'run'          => 'Run'
      }.freeze

      def child_node_class(name)
        Object.const_get("#{self.class}::#{KNOWN_NODES[name.to_s]}")
      rescue NameError
        nil
      end
    end

    # rubocop:disable Style/Documentation
    class Metamachine < Base
      def call(&block)
        ::Metamachine::Machine.new(context).tap do |m|
          @machine = m
          @machine.register!

          instance_eval(&block) if block_given?
        end
      end

      class StateReader < Base
        def call(reader)
          machine.state_reader = reader
        end
      end

      class State < Base
        def call(*states)
          machine.states.concat states.map(&:to_s)
        end
      end

      class Event < Base
        attr_reader :name

        def call(name, &block)
          @name = name.to_s

          machine.register_event(@name)

          instance_eval(&block) if block_given?
        end

        class Transition < Base
          def call(from:, to:)
            machine.register_transition(context.name, from, to)
          end
        end
      end

      class Run < Base
        def call(&block)
          machine.register_runner(&block)
        end
      end
    end
    # rubocop:enable Style/Documentation

    # Root method
    def metamachine(&block)
      DSL::Metamachine.new(self).call(&block)
    end
  end
end
