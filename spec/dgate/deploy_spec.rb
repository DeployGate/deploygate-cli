describe Dgate::Deploy do
  describe "#push" do
    context "raise error" do
      it "NotLoginError" do
        allow_any_instance_of(Dgate::Session).to receive(:login?) { false }

        expect {
          Dgate::Deploy.push(test_file_path, 'test', 'message')
        }.to raise_error Dgate::Deploy::NotLoginError
      end

      it "NotFileExistError" do
        expect {
          Dgate::Deploy.push('no_file_path', 'test', 'message')
        }.to raise_error Dgate::Deploy::NotFileExistError
      end

      it "UploadError" do
        allow_any_instance_of(Dgate::Session).to receive(:login?) { true }
        allow(Dgate::API::V1::Push).to receive(:upload).and_return({:error => true, :message => 'error message'})

        expect {
          Dgate::Deploy.push(test_file_path, 'test', 'message')
        }.to raise_error Dgate::Deploy::UploadError
      end
    end

    context "success" do
      it "default" do
        allow(Dgate::API::V1::Push).to receive(:upload).and_return({:error => false})
        allow_any_instance_of(Dgate::Session).to receive(:login?) { true }

        expect {
          Dgate::Deploy.push(test_file_path, 'test', 'message')
        }.not_to raise_error
      end
    end
  end
end
