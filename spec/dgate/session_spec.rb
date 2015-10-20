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

      Dgate::Session.delete
      expect {
        Dgate::Session.login('test@example.com', 'test')
      }.not_to raise_error
      expect(call_save).to be_truthy
      expect(Dgate::Session.new.login?).to be_truthy
    end

    it "failed" do
      data = {
          :error => true,
          :message => 'error message'
      }
      allow(Dgate::API::V1::Session).to receive(:login).and_return(data)

      expect {
        Dgate::Session.login('test@example.com', 'test')
      }.to raise_error(Dgate::Session::LoginError)
    end
  end

  describe "#save" do
    it "call Config.write" do
      config_data = {
          :name => 'test',
          :token => 'token'
      }
      call_config_write_and_fix_config = false
      allow(Dgate::Config).to receive(:write) { |c| call_config_write_and_fix_config = c == config_data}


      Dgate::Session.save(config_data[:name], config_data[:token])
      expect(call_config_write_and_fix_config).to be_truthy
    end
  end

  describe "#delete" do
    it "call save" do
      call_save = false
      allow(Dgate::Session).to receive(:save) { |name, token| call_save = (name == '' && token == '')}


      Dgate::Session.delete
      expect(call_save).to be_truthy

      login = Dgate::Session.new.login?
      expect(login).to be_falsey
    end
  end
end
