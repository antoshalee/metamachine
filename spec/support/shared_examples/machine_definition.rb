shared_examples 'machine definition' do
  it 'builds machine and adds it to registry' do
    expect { subject }
      .to change(Metamachine::Registry, :size)
      .by(1)
  end

  it 'defines state reader' do
    expect(subject.state_reader).to eq state_reader
  end

  context 'with wrong state reader type' do
    let(:state_reader) { 1 }

    it 'fails' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
