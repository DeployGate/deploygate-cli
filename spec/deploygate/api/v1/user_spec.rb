describe DeployGate::API::V1::User do
  describe "#create" do
    it "success" do
      name = 'test'
      email = 'email'
      password = 'password'
      token = 'token'
      response = {
          :error => false,
          :because => '',
          :results => {
              :user => {:name => name},
              :api_token => token
          }
      }
      stub_request(:post, "#{API_ENDPOINT}/users").
          to_return(:body => response.to_json)

      results = DeployGate::API::V1::User.create(name, email, password)
      expect(results).to eq({
                                :error => response[:error],
                                :message => response[:because],
                                :name => name,
                                :token => token
                            })
    end
  end

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
