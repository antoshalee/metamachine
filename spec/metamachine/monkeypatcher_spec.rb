RSpec.describe Metamachine::Monkeypatcher do
  subject { described_class.call(klass, event_name) }
  let(:klass) { Class.new }
  let(:instance) { klass.new }
  let(:event_name) { 'archive' }

  it 'defines instance method' do
    expect { subject }
      .to change { instance.respond_to?(:archive) }
      .from(false)
      .to(true)
  end

  describe 'defined method' do
    subject do
      described_class.call(klass, event_name)
      instance.archive
    end

    let(:machine) { Metamachine.register(klass) }
    let(:transition) { double }

    before do
      allow(machine).to receive(:dispatch_event).and_return(transition)
    end

    it 'delegates call to machine' do
      subject
      expect(machine).to have_received(:dispatch_event)
    end

    it 'returns transition' do
      expect(subject).to eq(transition)
    end
  end
end
