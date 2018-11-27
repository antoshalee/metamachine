RSpec.describe Metamachine do
  describe '.fire_event' do
    let(:instance) { double }
    let(:event_name) { 'publish' }

    subject { described_class.fire_event(instance, event_name) }

    it 'fires event' do
      allow(instance).to receive(:handle_metamachine_event)

      subject

      expect(instance)
        .to have_received(:handle_metamachine_event)
        .with(instance_of(Metamachine::Event))
    end
  end
end
