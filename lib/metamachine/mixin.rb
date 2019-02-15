# frozen_string_literal: true

module Metamachine
  # Extend your class with this module in order to
  # allow metamachine DSL:
  #
  #   class YourClass
  #     extend Metamachine::Mixin
  #
  #     metamachine do
  #       ..
  #     end
  #  end
  module Mixin
    def metamachine(&block)
      machine = Metamachine.register(
        self,
        &block
      )

      machine.events.each_key do |event_name|
        Monkeypatcher.call(self, event_name)
      end
    end
  end
end
