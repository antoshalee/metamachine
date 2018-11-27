RSpec.describe Metamachine::Definition::Event do
  let(:event) { described_class.new(:publish) }

  describe '#name' do
    subject { event.name }

    it('stringified') { is_expected.to eq 'publish' }
  end

  describe '#transition' do
    subject { event.transition(from: from, to: to) }

    let(:from) { ['created', :archived, 'deleted'] }

    let(:to) { :published }

    it 'adds transitions' do
      expect { subject }
        .to change { event.transitions.size }
        .by(3)
    end

    it 'all states are strings' do
      subject

      expect(event.transitions.keys).to all(be_a(String))
      expect(event.transitions.values).to all(be_a(String))
    end

    context 'when `from` is not Array' do
      let(:from) { 'created' }

      it 'works' do
        expect { subject }
          .to change { event.transitions.size }
          .by(1)
      end
    end
  end
end
