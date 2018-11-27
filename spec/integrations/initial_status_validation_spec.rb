RSpec.describe 'initial status validation' do
  let(:klass) do
    Class.new do
      attr_accessor :status, :author

      include Metamachine

      metamachine(:status) do
        state :draft, :published, :archived

        event :publish do
          transition from: :draft, to: :published
        end
      end

      def metamachine_run(event); end
    end
  end

  it 'works' do
    post = klass.new
    post.status = 'archived'

    expect { post.publish }
      .to raise_error(Metamachine::InvalidTransitionInitialState)
  end
end
