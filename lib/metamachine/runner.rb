module Metamachine
  class Runner
    def initialize(&block)
      @runner_code = Proc.new(&block)
      @active_transitions = Concurrent::Map.new
    end

    def run(transition)
      avoid_nested_transitions_for(transition.target) do
        runner_code.call(transition)
      end
    end

    private

    def avoid_nested_transitions_for(target)
      raise Metamachine::NestedTransitionsError if active_transitions[target]

      lock_target(target)

      yield

      unlock_target(target)
    end

    def lock_target(target)
      active_transitions[target] = true
    end

    def unlock_target(target)
      active_transitions.delete(target)
    end

    attr_reader :runner_code,
                :active_transitions
  end
end
