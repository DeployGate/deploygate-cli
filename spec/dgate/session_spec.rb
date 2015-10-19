describe Dgate::Session do
  describe "#login?" do
    it "call check api" do
      call_check = false
      allow(Dgate::API::V1::Session).to receive(:check) { call_check = true }

      Dgate::Session.new.login?
      expect(call_check).to be_truthy
    end
  end

  describe "#login" do
    it "success" do
      data = {
          :error => false,
          :name => 'test',
          :token => 'token'
      }
      call_save = false
      allow(Dgate::API::V1::Session).to receive(:login).and_return(data)
      allow(Dgate::Session).to receive(:save) { call_save = true }

      result = Dgate::Session.login('test@example.com', 'test')
      expect(result).to eq(data)
      expect(call_save).to be_truthy
    end

    it "failed" do
      data = {
          :error => true,
      }
      call_save = false
      allow(Dgate::API::V1::Session).to receive(:login).and_return(data)
      allow(Dgate::Session).to receive(:save) { call_save = true }

      result = Dgate::Session.login('test@example.com', 'test')
      expect(result).to eq(data)
      expect(call_save).to be_falsey
    end
  end

  describe "#save" do
    # TODO: replace ENV["HOME"]
  end

  describe "#delete" do
    # TODO: replace ENV["HOME"]
  end
end
