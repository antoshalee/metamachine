RSpec.describe Metamachine::Definition::Machine do
  let(:machine) { described_class.new(klass, :status) }
  let(:klass) { Class.new }

  describe '#state_reader' do
    subject { machine.state_reader }

    it 'stringified' do
      is_expected.to be_a(String)
    end
  end

  describe '#state' do
    subject { machine.state(*states) }

    let(:states) { [:created, 'published', 'archived'] }

    it 'adds states' do
      expect { subject }
        .to change { machine.states.size }
        .by(3)
    end

    it 'all states are strings' do
      expect(subject).to all(be_a(String))
    end
  end

  describe '#event' do
    subject do
      machine.event(:publish) do
        transition from: :created, to: :published
      end
    end

    it 'raises' do
      expect { subject }.to raise_error(Metamachine::Definition::UnknownState)
    end

    context 'when states are defined' do
      before do
        machine.state :created, :published
      end

      it 'adds events' do
        expect { subject }
          .to change { machine.events.size }
          .by(1)
      end

      it 'monkeypatches klass' do
        expect(klass.instance_methods).not_to include(:publish)

        subject

        expect(klass.instance_methods).to include(:publish)
      end
    end
  end
end
