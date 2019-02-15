module Metamachine
  # Registry of all defined machines
  class Registry
    @machines = Concurrent::Map.new

    class << self
      attr_reader :machines

      extend Forwardable

      def_delegators :@machines,
                     :[],
                     :[]=,
                     :size
    end
  end
end
