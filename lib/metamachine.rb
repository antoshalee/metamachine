# frozen_string_literal: true

# Define your first machine with:
#
#   Metamachine.register(key) do
#     state_reader :status
#     state :draft, :published
#
#     event :publish do
#       transition from: :draft, to: :published
#     end
#
#     run do |transition, obj|
#       obj.status = transition.state_to
#     end
#   end
module Metamachine
  require 'concurrent'
  require_relative 'metamachine/machine'
  require_relative 'metamachine/registry'
  require_relative 'metamachine/mixin'
  require_relative 'metamachine/dsl'
  require_relative 'metamachine/monkeypatcher'
  require_relative 'metamachine/transition'
  require_relative 'metamachine/dispatch'
  require_relative 'metamachine/runner'

  InvalidTransitionInitialState = Class.new(StandardError)
  NotExpectedResultState        = Class.new(StandardError)
  NestedTransitionsError        = Class.new(StandardError)

  class << self
    def register(key, &dsl)
      Registry[key] = Machine.new(&dsl)
    end
  end
end
