RSpec.describe 'invalid runner' do
  let(:klass) do
    Class.new do
      attr_accessor :status, :author

      extend Metamachine::DSL

      metamachine do
        state_reader :status
        state :draft, :published, :archived

        event :publish do
          transition from: :draft, to: :published
        end

        # Runner is doing nothing here which is obviously wrong
        run {}
      end
    end
  end

  it 'fails' do
    post = klass.new
    post.status = 'draft'

    expect { post.publish }.to raise_error(Metamachine::NotExpectedResultState)
  end
end
