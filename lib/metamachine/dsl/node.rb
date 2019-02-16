# frozen_string_literal: true

module Metamachine
  module DSL
    # Base class for all DSL nodes
    # Node reflects method execution and it's class name reflects a chain:
    #
    # E.g. `Root::Node_event::Node_transition` is a class for a node
    # which actually executes `event.transition`
    class Node
      attr_reader :context,
                  :parent

      def initialize(context = {}, parent = nil)
        @context = context
        @parent = parent
      end

      # rubocop:disable Style/MethodMissing
      def method_missing(method, *args, &block)
        Object
          .const_get("#{self.class}::Node_#{method}")
          .new(context, self)
          .call(*args, &block)
      end

      def machine
        context[:machine]
      end
    end
  end
end
