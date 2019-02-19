module Metamachine
  # Provides methods for contract defining
  module Assertion
    Error = Class.new(StandardError)

    # rubocop:disable Layout/IndentHeredoc
    def assert_value!(actual, expected, violation_name)
      return if actual == expected

      raise(Error, <<-MSG)
Contract violation for the #{violation_name}
Actual: '#{actual}'.
Expected: '#{expected}'
MSG
    end
    # rubocop:enable Layout/IndentHeredoc
  end
end
