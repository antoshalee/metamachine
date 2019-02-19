module Metamachine
  class Runner
    NestedTransitionError = Class.new(StandardError)

    def initialize(&block)
      @run_block = Proc.new(&block)
      @running_transitions = Concurrent::Map.new
    end

    def run(transition)
      avoid_nested_transitions_for(transition.target) do
        run_block.call(transition)
      end
    end

    private

    def avoid_nested_transitions_for(target)
      lock_target(target)

      yield

      unlock_target(target)
    end

    def lock_target(target)
      # `put_if_absent` returns value if key already exists
      # In this happens we fail
      raise NestedTransitionError if
        running_transitions.put_if_absent(target, true)
    end

    def unlock_target(target)
      running_transitions.delete(target)
    end

    attr_reader :run_block,
                :running_transitions
  end
end
