# frozen_string_literal: true

module Metamachine
  require_relative 'metamachine/definition'
  require_relative 'metamachine/transition'
  require_relative 'metamachine/dispatch'
  require_relative 'metamachine/runner'

  InvalidTransitionInitialState = Class.new(StandardError)
  NotExpectedResultState        = Class.new(StandardError)
  NestedTransitionsError        = Class.new(StandardError)

  class << self
    def included(base)
      base.extend Metamachine::Definition

      super
    end
  end
end
