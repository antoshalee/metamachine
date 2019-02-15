RSpec.describe Metamachine::DSL do
  let(:klass) do
    Class.new do
      extend Metamachine::DSL
    end
  end

  let(:state_reader) { :my_awesome_status }

  describe '#metamachine' do
    subject { klass.metamachine(state_reader) }

    include_examples 'machine definition'
  end

  describe 'specific dsl methods' do
    subject { node }

    let(:node) { described_class.new(context, machine) }
    let(:machine) { Metamachine::Machine.new(klass, state_reader) }
    let(:context) { nil }

    describe Metamachine::DSL::Metamachine do
      let(:context) { klass }
      let(:machine) { nil }

      it { is_expected.to respond_to :state }
      it { is_expected.to respond_to :event }
      it { is_expected.to respond_to :run }
      it { is_expected.not_to respond_to :transition }

      describe '#call' do
        subject { node.call(state_reader) }

        include_examples 'machine definition'
      end
    end

    describe Metamachine::DSL::Metamachine::State do
      describe '#call' do
        subject { node.call(:published, 'archived') }

        it 'adds states and stringifies them' do
          expect { subject }
            .to change(machine.states, :size)
            .by 2

          expect(machine.states[0]).to eq 'published'
          expect(machine.states).to all(be_a String)
        end
      end
    end

    describe Metamachine::DSL::Metamachine::Event do
      it { is_expected.to respond_to :transition }

      describe '#call' do
        subject { node.call(:publish) }

        it 'adds event' do
          expect { subject }
            .to change(machine.events, :size)
            .by(1)

          expect(machine.events['publish']).to eq({})
        end
      end
    end

    describe Metamachine::DSL::Metamachine::Event::Transition do
      let!(:context) do
        Metamachine::DSL::Metamachine::Event.new(nil, machine).tap do |evt_node|
          evt_node.call('archive')
        end
      end

      describe '#call' do
        subject { node.call(from: :published, to: :archived) }

        it 'adds transition' do
          expect { subject }
            .to change(machine.events['archive'], :size)
            .by(1)

          expect(machine.events['archive']['published']).to eq 'archived'
        end
      end
    end
  end
end
