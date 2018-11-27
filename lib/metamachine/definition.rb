# frozen_string_literal: true

module Metamachine
  module Definition
    require 'concurrent'
    require_relative 'definition/machine'
    require_relative 'definition/event'
    require_relative 'definition/monkeypatcher'

    UnknownState = Class.new(StandardError)

    @machines = Concurrent::Map.new

    class << self
      attr_reader :machines
    end

    def metamachine(*args, &block)
      Definition.machines[self] ||= Machine.new(self, *args, &block)
    end
  end
end
