describe DeployGate::API::V1::User do
  describe "#registered?" do
    it "registered" do
      name = 'test'
      response = {
          :error => false,
          :because => '',
          :results => {:registered => true}
      }
      stub_request(:get, "#{API_ENDPOINT}/users/registered?email=&name=#{name}").
          to_return(:body => response.to_json)

      result = DeployGate::API::V1::User.registered?(name, '')
      expect(result).to be_truthy
    end

    it "not registered" do
      name = 'test'
      response = {
          :error => false,
          :because => '',
          :results => {:registered => false}
      }
      stub_request(:get, "#{API_ENDPOINT}/users/registered?email=&name=#{name}").
          to_return(:body => response.to_json)

      result = DeployGate::API::V1::User.registered?(name, '')
      expect(result).to be_falsey
    end
  end
end
