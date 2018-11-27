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
      end

      def metamachine_run(transition)
        transition.run do
          self.status = transition.expected_state

          if transition.expected_state == 'published'
            self.author = transition.params[:author]
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
end
