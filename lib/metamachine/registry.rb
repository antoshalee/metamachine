module Metamachine
  # Registry of all defined machines
  class Registry
    @machines = Concurrent::Map.new

    class << self
      attr_reader :machines

      def add(machine)
        machines[key_for(machine)] = machine
      end

      def get(target_class)
        machines[target_class]
      end

      def size
        machines.size
      end

      private

      def key_for(machine)
        machine.target_class
      end
    end
  end
end
