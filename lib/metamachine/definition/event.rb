module Metamachine
  module Definition
    class Event
      attr_reader :name, :transitions

      def initialize(name, &block)
        @name = name.to_s
        @transitions = {}

        instance_eval(&block) if block_given?
      end

      def transition(from:, to:)
        from = Array(from)
        to = to.to_s

        from.each { |f| transitions[f.to_s] = to }
      end
    end
  end
end
