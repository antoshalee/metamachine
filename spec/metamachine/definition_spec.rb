RSpec.describe Metamachine::Definition do
  let(:klass) do
    Class.new do
      extend Metamachine::Definition
    end
  end

  let(:definition) do
    proc do
      state :created, :published

      event :publish do
      end
    end
  end

  it 'works' do
    expect { klass.metamachine(:status, &definition) }
      .to change { described_class.machines.size }
      .by(1)

    machine = described_class.machines[klass]

    expect(machine.states.size).to eq 2
    expect(machine.events.size).to eq 1
  end
end
