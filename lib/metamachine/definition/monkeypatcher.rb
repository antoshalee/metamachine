module Metamachine
  module Definition
    # Adds methods to the original class
    class Monkeypatcher
      HANDLE_METHOD = :handle_metamachine_event

      class << self
        def call(klass, event_name)
          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{event_name}(params = {})
              Metamachine::Dispatch.call(self, '#{event_name}', params)

              nil
            end
          RUBY
        end
      end
    end
  end
end
