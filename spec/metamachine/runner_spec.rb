RSpec.describe Metamachine::Runner do
  let(:runner) { described_class.new { } }

  describe '#run' do
    let(:transition) { double(target: target) }
    let(:target) { double }

    it 'runs block' do
      expect do |b|
        runner = described_class.new(&b)
        runner.run(transition)
      end.to yield_with_args(transition)
    end

    context 'with active transition for target' do
      before { runner.send(:lock_target, target) }

      it 'fails' do
        expect { runner.run(transition) }
          .to raise_error(Metamachine::NestedTransitionsError)
      end
    end
  end
end
