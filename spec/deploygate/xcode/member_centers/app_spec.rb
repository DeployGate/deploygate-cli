describe DeployGate::Xcode::MemberCenters::App do
  before do
    allow_any_instance_of(DeployGate::Xcode::MemberCenter).to receive(:instance) {}
    allow(Spaceship).to receive(:app).and_return(SpaceshipApp.new(uuid))
  end

  class SpaceshipApp
    attr_reader :bundle_id
    def initialize(bundle_id)
      @bundle_id = bundle_id
    end
    def create!(options)
    end

    def all
    end
  end

  let(:uuid) { 'com.example.test' }
  let(:app) { DeployGate::Xcode::MemberCenters::App.new(uuid) }

  context "#created?" do
    let(:registered_uuid) { 'com.example.test.registered' }
    let(:non_registered_uuid) { 'com.example.test.non.registered' }

    before do
      allow_any_instance_of(SpaceshipApp).to receive(:all) do
        [SpaceshipApp.new(registered_uuid)]
      end
    end

    it "app created" do
      app = DeployGate::Xcode::MemberCenters::App.new(registered_uuid)

      expect(app.created?).to be_truthy
    end

    it "no app created" do
      app = DeployGate::Xcode::MemberCenters::App.new(non_registered_uuid)

      expect(app.created?).to be_falsey
    end
  end

  context "#create!" do
    it "must call Spaceshio.app.create!" do
      call_create = false
      allow_any_instance_of(SpaceshipApp).to receive(:create!) { call_create = true }

      app.create!
      expect(call_create).to be_truthy
    end
  end

  context "#name" do
    it "get name" do
      expect(app.name).to eq 'com example test'
    end
  end
end
