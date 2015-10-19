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
    end

    context "success" do
      it "default" do
        call_push_upload = false

        allow(Dgate::API::V1::Push).to receive(:upload) { call_push_upload = true }
        allow_any_instance_of(Dgate::Session).to receive(:login?) { true }

        Dgate::Deploy.push(test_file_path, 'test', 'message')
        expect(call_push_upload).to be_truthy
      end
    end
  end
end
