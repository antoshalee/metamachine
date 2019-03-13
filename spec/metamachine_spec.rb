RSpec.describe Metamachine do
  describe '.register' do
    subject { Metamachine.register('key') }

    it 'works' do
      expect { subject }.to change(Metamachine::Registry, :size).by(1)
    end
  end
end
