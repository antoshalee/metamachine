module Metamachine
  class Dispatch
    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(target, name, params)
      @target = target
      @name   = name
      @params = params
    end

    def call
      machine = Metamachine::Definition.machines[target.class]

      transition = machine.build_transition(name, target, params)

      machine.run_transition(transition)

      transition.validate_result!
    end

    private

    attr_reader :target,
                :name,
                :params
  end
end
