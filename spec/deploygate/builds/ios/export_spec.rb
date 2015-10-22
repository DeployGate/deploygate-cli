describe DeployGate::Builds::Ios::Export do
  describe "#method" do
    it "only ad-hoc user" do
      allow(DeployGate::Builds::Ios::Export).to receive(:profiles).and_return(['adhoc'])
      allow(DeployGate::Builds::Ios::Export).to receive(:inhouse?).and_return(false)
      expect(DeployGate::Builds::Ios::Export.method).to eq DeployGate::Builds::Ios::Export::AD_HOC
    end

    it "inhouse user" do
      allow(DeployGate::Builds::Ios::Export).to receive(:profiles).and_return(['inhouse'])
      allow(DeployGate::Builds::Ios::Export).to receive(:inhouse?).and_return(true)
      expect(DeployGate::Builds::Ios::Export.method).to eq DeployGate::Builds::Ios::Export::ENTERPRISE
    end
  end
end
