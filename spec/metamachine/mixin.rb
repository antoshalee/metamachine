RSpec.describe Metamachine::Mixin do
  let(:klass) do
    Class.new do
      extend Metamachine::Mixin
    end
  end

  it 'defines metamachine method on class' do
    expect { klass.to respond_to(:metamachine) }
  end

  describe '.metamachine' do
    subject do
      klass.metamachine do
        event :publish
      end
    end

    let(:post) { klass.new }

    include_examples 'machine definition'

    it 'defines instance method to dispatch event directly' do
      subject

      expect(post).to respond_to :publish
    end
  end
end


