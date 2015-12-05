describe DeployGate::Deploy do
  describe "#push" do
    context "raise error" do
      it "NotLoginError" do
        allow_any_instance_of(DeployGate::Session).to receive(:login?) { false }

        expect {
          DeployGate::Deploy.push(test_file_path, 'test', 'message', nil)
        }.to raise_error DeployGate::Deploy::NotLoginError
      end

      it "NotFileExistError" do
        expect {
          DeployGate::Deploy.push('no_file_path', 'test', 'message', nil)
        }.to raise_error DeployGate::Deploy::NotFileExistError
      end

      it "UploadError" do
        allow_any_instance_of(DeployGate::Session).to receive(:login?) { true }
        allow(DeployGate::API::V1::Push).to receive(:upload).and_return({:error => true, :message => 'error message'})

        expect {
          DeployGate::Deploy.push(test_file_path, 'test', 'message', nil)
        }.to raise_error DeployGate::Deploy::UploadError
      end
    end

    context "success" do
      it "default" do
        allow(DeployGate::API::V1::Push).to receive(:upload).and_return({:error => false})
        allow_any_instance_of(DeployGate::Session).to receive(:login?) { true }

        expect {
          DeployGate::Deploy.push(test_file_path, 'test', 'message', nil)
        }.not_to raise_error
      end
    end
  end
end
