describe DeployGate::Xcode::MemberCenter do
  class SpaceshipClient
    def in_house?
    end
  end

  let(:email) { 'test@example.com' }
  let(:center) { DeployGate::Xcode::MemberCenter.instance }
  before do
    allow(Spaceship).to receive(:login) {}
    allow(Spaceship).to receive(:select_team) {}
    allow(Spaceship).to receive(:client).and_return(SpaceshipClient.new)
    allow_any_instance_of(DeployGate::Xcode::MemberCenter).to receive(:input_email).and_return(email)
  end

  context '#initialize' do
    it "input email" do
      expect(center.email).to eq email
    end
  end
end
