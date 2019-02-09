# frozen_string_literal: true

module Metamachine
  require 'concurrent'
  require_relative 'metamachine/machine'
  require_relative 'metamachine/registry'
  require_relative 'metamachine/dsl'
  require_relative 'metamachine/monkeypatcher'
  require_relative 'metamachine/transition'
  require_relative 'metamachine/dispatch'
  require_relative 'metamachine/runner'

  InvalidTransitionInitialState = Class.new(StandardError)
  NotExpectedResultState        = Class.new(StandardError)
  NestedTransitionsError        = Class.new(StandardError)

  class << self
    def included(base)
      base.extend Metamachine::DSL

      super
    end
  end
end
