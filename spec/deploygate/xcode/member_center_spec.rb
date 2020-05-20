describe DeployGate::Xcode::MemberCenter do
  class SpaceshipClient
    def in_house?
    end
  end

  let(:email) { 'test@example.com' }
  let(:center) { DeployGate::Xcode::MemberCenter.new('com-example-team-id') }
  before do
    allow_any_instance_of(Spaceship::PortalClient).to receive(:login) {}
    allow_any_instance_of(Spaceship::PortalClient).to receive(:teams) {['team_name', 'team_id']}
    allow_any_instance_of(Spaceship::Launcher).to receive(:select_team) {}
    allow_any_instance_of(DeployGate::Xcode::MemberCenter).to receive(:input_email).and_return(email)
  end

  context '#initialize' do
    it "input email" do
      expect(center.email).to eq email
    end
  end
end
