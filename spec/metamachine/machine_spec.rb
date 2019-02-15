RSpec.describe Metamachine::Machine do
  let(:machine) { described_class.new }

  describe "#dispatch_event" do
    subject { machine.dispatch_event(event, post, params) }

    let(:event) { 'publish' }
    let(:post) { TestPost.new }
    let(:params) { {} }

    it 'delegates call to Dispatcher' do
      allow(Metamachine::Dispatch).to receive(:call)

      subject

      expect(Metamachine::Dispatch)
        .to have_received(:call).with(machine, event, post, params)
    end
  end
end
