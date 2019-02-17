module Metamachine
  # Adds methods to the original class
  class Monkeypatcher
    class << self
      def call(klass, event_name)
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{event_name}(params = {})
            machine = Metamachine::Registry[self.class]
            machine.dispatch_event('#{event_name}', self, params)
          end
        RUBY
      end
    end
  end
end
