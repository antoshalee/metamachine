# frozen_string_literal: true

module Metamachine
  # Machine definition
  module DSL
    require_relative 'dsl/node'

    # rubocop:disable Style/Documentation
    # rubocop:disable Style/ClassAndModuleChildren
    # rubocop:disable Naming/ClassAndModuleCamelCase
    class Root < Node
      def call(&block)
        instance_eval(&block) if block_given?
      end
    end

    class Root::Node_state_reader < Node
      def call(reader)
        unless reader.is_a?(Symbol) || reader.is_a?(String)
          raise ArgumentError, 'State reader must be a String or a Symbol'
        end

        machine.instance_variable_set(:@state_reader, reader)
      end
    end

    class Root::Node_states < Node
      def call(*states)
        machine.states.concat states.map(&:to_s)
      end
    end

    class Root::Node_event < Node
      attr_reader :event_name

      def call(name, &block)
        @event_name = name.to_s

        machine.transitions_map[event_name] = {}

        instance_eval(&block) if block_given?
      end
    end

    class Root::Node_event::Node_transition < Node
      def call(from:, to:)
        Array(from).each do |f|
          machine.transitions_map[parent.event_name][f.to_s] = to.to_s
        end
      end
    end

    class Root::Node_run < Node
      def call(&block)
        machine.instance_variable_set(
          :@runner,
          Metamachine::Runner.new(&block)
        )
      end
    end
  end
end
