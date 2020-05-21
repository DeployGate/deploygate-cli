describe DeployGate::Xcode::MemberCenters::App do
  let(:email) { 'test@example.com' }
  let(:registered_uuid) { 'com.example.test.registered' }
  let(:non_registered_uuid) { 'com.example.test.non.registered' }
  let(:member_center) { DeployGate::Xcode::MemberCenter.new('com-example-team-id') }
  let(:app) { DeployGate::Xcode::MemberCenters::App.new('com.example.test.new.app', member_center) }

  before do
    allow_any_instance_of(Spaceship::PortalClient).to receive(:login) {}
    allow_any_instance_of(Spaceship::PortalClient).to receive(:teams) {['team_name', 'team_id']}
    allow_any_instance_of(Spaceship::Launcher).to receive(:select_team) {}
    allow_any_instance_of(Spaceship::PortalClient).to receive(:apps) {[
        {"identifier" => registered_uuid}
    ]}
    allow_any_instance_of(DeployGate::Xcode::MemberCenter).to receive(:input_email).and_return(email)
  end


  context "#created?" do

    it "app created" do
      app = DeployGate::Xcode::MemberCenters::App.new(registered_uuid, member_center)

      expect(app.created?).to be_truthy
    end

    it "no app created" do
      app = DeployGate::Xcode::MemberCenters::App.new(non_registered_uuid, member_center)

      expect(app.created?).to be_falsey
    end
  end

  context "#create!" do
    it "must call Spaceshio.app.create!" do
      call_create = false
      allow(Spaceship::Portal::App).to receive(:create!) { call_create = true }

      app.create!
      expect(call_create).to be_truthy
    end
  end

  context "#name" do
    it "get name" do
      expect(app.name).to eq 'com example test new app'
    end
  end
end
