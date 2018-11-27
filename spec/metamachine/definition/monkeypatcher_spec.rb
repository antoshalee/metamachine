RSpec.describe Metamachine::Definition::Monkeypatcher do
  subject { described_class.call(klass, event_name) }

  let(:klass) { Class.new }
  let(:instance) { klass.new }
  let(:event_name) { 'publish' }

  before { subject }

  it 'defines instance methods' do
    expect(instance).to respond_to(:publish)
  end

  describe 'event method' do
    context 'without defined #handle_metamachine_event' do
      it 'fails' do
        expect { instance.publish }.to raise_error(NotImplementedError)
      end
    end

    context 'with defined #handle_metamachine_method' do
      before do
        klass.send(:define_method, 'handle_metamachine_event') { |_evt| nil }
      end

      it 'works' do
        expect { instance.publish }.not_to raise_error
      end

      it 'fires event' do
        allow(instance).to receive(:handle_metamachine_event)

        instance.publish

        expect(instance)
          .to have_received(:handle_metamachine_event)
          .with(instance_of(Metamachine::Event))
      end
    end
  end
end
