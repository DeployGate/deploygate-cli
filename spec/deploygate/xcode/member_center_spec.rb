describe DeployGate::Xcode::MemberCenter do
  before do
    allow(Spaceship).to receive(:login) {}
    allow(Spaceship).to receive(:select_team) {}
  end

  let(:email) { 'test@example.com' }
  it "input email" do
    allow_any_instance_of(DeployGate::Xcode::MemberCenter).to receive(:input_email).and_return(email)

    expect(DeployGate::Xcode::MemberCenter.instance.email).to eq email
  end
end
