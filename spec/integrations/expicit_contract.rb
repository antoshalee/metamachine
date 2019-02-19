RSpec.describe 'success' do
  let(:klass) do
    Class.new do
      attr_accessor :status, :author

      extend Metamachine::Mixin

      metamachine do
        state_reader :status

        states :draft, :published, :archived

        event :publish do
          transition from: :draft, to: :published
        end

        run do |transition|
          begin
            transition.contract!(transition.target) do
              transition.target.status = nil
            end
          rescue Metamachine::Contract::PostconditionsError
            raise 'custom postconditions error'
          end
        end
      end
    end
  end

  it 'works' do
    post = klass.new
    post.status = 'draft'

    expect { post.publish }
      .to raise_error(RuntimeError, 'custom postconditions error')
  end
end
