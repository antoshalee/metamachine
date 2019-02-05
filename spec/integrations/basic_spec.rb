RSpec.describe 'success' do
  let(:klass) do
    Class.new do
      attr_accessor :status, :author

      include Metamachine

      metamachine(:status) do
        state :draft, :published, :archived

        event :publish do
          transition from: :draft, to: :published
        end

        event :archive do
          transition from: %i[draft published], to: :archived
        end

        run do |transition, obj|
          obj.status = transition.state_to

          if transition.state_to == 'published'
            obj.author = transition.params[:author]
          end
        end
      end
    end
  end

  it 'works' do
    post = klass.new
    post.status = 'draft'

    expect { post.publish(author: 'Harms') }
      .to change(post, :status)
      .from('draft').to('published')
      .and change { post.author }
      .from(nil).to('Harms')

    expect { post.archive }
      .to change(post, :status)
      .to('archived')
  end

  describe 'invalid state from' do
    it 'fails' do
      post = klass.new
      post.status = 'archived'

      expect { post.publish }
        .to raise_error(Metamachine::InvalidTransitionInitialState)
    end
  end
end
