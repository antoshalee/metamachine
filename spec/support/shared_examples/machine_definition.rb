shared_examples 'machine definition' do
  it 'builds machine and adds it to registry' do
    expect { subject }
      .to change(Metamachine::Registry, :size)
      .by(1)
  end
end
