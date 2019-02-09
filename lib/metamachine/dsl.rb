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

      def child_node_class(name)
        Object.const_get("#{self.class}::#{name.to_s.capitalize}")
      rescue NameError
        nil
      end
    end

    # rubocop:disable Style/Documentation
    class Metamachine < Base
      def call(state_reader, &block)
        ::Metamachine::Machine.new(context, state_reader).tap do |m|
          @machine = m
          @machine.register!

          instance_eval(&block) if block_given?
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
    def metamachine(state_reader, &block)
      DSL::Metamachine.new(self).call(state_reader, &block)
    end
  end
end
