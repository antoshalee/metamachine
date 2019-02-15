RSpec.describe 'success' do
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

        run do |transition|
          transition.target.status = transition.state_to
        end
      end
    end
  end

  it 'works' do
    post = klass.new
    post.status = 'draft'

    expect { post.publish }
      .to change(post, :status)
      .to('published')
  end
end
