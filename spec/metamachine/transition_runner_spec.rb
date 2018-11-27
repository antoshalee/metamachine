RSpec.describe Metamachine::TransitionRunner do
  let(:event) do
    Metamachine::Event.new(
      key:            :publish,
      object:         object,
      machine:        double,
      initial_state:  :draft
    )
  end

  TestObjectClass = Struct.new(:status)

  let(:object) { TestObjectClass.new('draft') }
  let(:expected_state) { 'published' }

  it 'raises if block is not given' do
    expect { described_class.call(event) }
      .to raise_error(Metamachine::TransitionRunner::BlockNotGiven)
  end

  it 'does not raise if block is given' do
    expect { described_class.call(event) { nil } }
      .not_to raise_error(Metamachine::TransitionRunner::BlockNotGiven)
  end

  it 'raises if result state is not expected' do
    expect { described_class.call(event) { object.status = 'closed' } }
      .to raise_error(Metamachine::NotExpectedStatus)
  end
end
