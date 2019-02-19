RSpec.describe Metamachine::StateContract do
  def contract!(target, &block)
    described_class.new(
      state_from:   'draft',
      state_to:     'published',
      state_reader: 'state'
    ).call(target, &block)
  end

  let(:target) { Struct.new(:state).new(initial_state) }
  let(:initial_state) { 'draft' }

  context 'with valid initial state' do
    context 'with valid state transition' do
      subject { contract!(target) { target.state = 'published' } }

      it 'succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'with invalid state transition' do
      subject { contract!(target) { target.state = 'archived' } }

      it 'succeed' do
        expect { subject }
          .to raise_error(Metamachine::Assertion::Error)
      end
    end
  end

  context 'with invalid initial target state' do
    let(:initial_state) { 'draft1' }

    it 'checks pre-conditions' do
      expect { contract!(target) {} }
        .to raise_error(Metamachine::Assertion::Error)
    end
  end
end
