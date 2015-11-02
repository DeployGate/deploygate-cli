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
end
