module Metamachine
  # This holds all context of a specific transition:
  # target, event params and contract
  # Specific transition will be passed to the runner call as a parameter
  class Transition
    include DefInitialize.with('event_name:, target:, params: {}, contract:',
                               readers: :public)

    extend Forwardable

    def_delegators :@contract,
                   :state_from,
                   :state_to

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
