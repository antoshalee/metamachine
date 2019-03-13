# frozen_string_literal: true

module Metamachine
  # Wrapper for a code which asserts the following:
  # 1) Precondition: initial state of a passed object must be equal
  # to a `state_from`
  # 2) Postcondition: result state must be equal to a `state_to`
  #
  # We pass `state_reader` to be able to inspect current state of an object
  class StateContract
    require_relative 'assertion'

    include Assertion

    include DefInitialize.with('state_from:, state_to:, state_reader:')

    def call(target)
      assert_value! target.send(state_reader), state_from, 'initial state'

      yield

      assert_value! target.send(state_reader), state_to, 'result state'
    end
  end
end
