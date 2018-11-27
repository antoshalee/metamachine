RSpec.describe Metamachine::Event do
  let(:event) { described_class.new(params) }

  let(:object_class) do
    Class.new do

    end
  end

  let(:object) { object_class.new }

  let(:params) do
    {
      key:            :publish,
      initial_state:  'draft',
      machine:        double,
      object:         object
    }
  end

  describe '#new' do
    it 'stringifies key and states' do
      expect(event.key).to eq 'publish'
      expect(event.initial_state).to eq 'draft'
    end
  end

  describe '#transition' do
    it 'raises if block is not given' do
      expect { event.transition }
        .to raise_error(Metamachine::TransitionRunner::BlockNotGiven)
    end

    it 'does not raise if block is given' do
      expect { event.transition { nil } }
        .not_to raise_error(Metamachine::TransitionRunner::BlockNotGiven)
    end
  end
end
