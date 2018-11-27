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

      transition = Metamachine::Transition.new(
        event: name,
        machine: machine,
        target: target,
        params: params
      )

      target.metamachine_run(transition)
    end

    private

    attr_reader :target,
                :name,
                :params
  end
end
