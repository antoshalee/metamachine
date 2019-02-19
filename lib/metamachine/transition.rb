module Metamachine
  # This holds all context of a specific transition:
  # target, event params and contract
  # Specific transition will be passed to the runner call as a parameter
  class Transition
    attr_reader :event_name,
                :target,
                :params

    extend Forwardable

    def_delegators :@contract,
                   :state_from,
                   :state_to

    def initialize(
      event_name:,
      target:,
      params: {},
      contract:
    )
      @event_name = event_name.to_s
      @target     = target
      @params     = params
      @contract   = contract
    end

    # Metamachine wraps runner by contract call
    # but it also provides this method
    # which allows one to run contract explicitly.
    # It can be useful if you want
    # exception to be raised in the middle of runner execution
    # e.g. in order to rollback transaction
    def contract!(*args, &block)
      @contract.call(*args, &block)
    end
  end
end
