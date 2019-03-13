RSpec.describe Metamachine::Machine do
  let(:machine) { described_class.new }

  describe "#dispatch_event" do
    subject { machine.dispatch_event(event, post, params) }

    let(:event) { 'publish' }
    let(:post) { TestPost.new }
    let(:params) { {} }

    it 'delegates call to Dispatch' do
      dispatcher = double(call: nil)

      allow(Metamachine::Dispatch).to receive(:new).with(machine, event, post, params).and_return(dispatcher)

      subject

      expect(dispatcher).to have_received(:call)
    end
  end
end
