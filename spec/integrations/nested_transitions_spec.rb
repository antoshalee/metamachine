RSpec.describe 'nested transitions' do
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

        event :archive do
          transition from: :draft, to: :archived
        end

        run do |transition|
          transition.target.archive
        end
      end
    end
  end

  it 'avoids recursion' do
    post = klass.new
    post.status = 'draft'

    expect { post.publish }.to raise_error(Metamachine::NestedTransitionsError)
  end
end
