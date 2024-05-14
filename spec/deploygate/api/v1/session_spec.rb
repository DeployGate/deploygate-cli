describe DeployGate::API::V1::Session do
  describe "#show" do
    it "logined" do
      token = 'token'
      name = 'test'
      response = {
          :error => false,
          :because => '',
          :results => {'name' => name}
      }
      stub_request(:get, "#{API_ENDPOINT}/sessions/user").
          with(:headers => { 'AUTHORIZATION' => "token #{token}" }).
          to_return(:body => response.to_json)


      results = DeployGate::API::V1::Session.show(token)
      expect(results).to eql response[:results]
    end

    it "not login" do
      token = 'token'
      response = {
          :error => true,
          :because => 'error message'
      }
      stub_request(:get, "#{API_ENDPOINT}/sessions/user").
          with(:headers => { 'AUTHORIZATION' => "token #{token}" }).
          to_return(:body => response.to_json)

      results = DeployGate::API::V1::Session.show(token)
      expect(results).to eql response[:results]
    end
  end
  describe "#check" do
    it "logined" do
      token = 'token'
      name = 'test'
      results = {'name' => name}
      allow(DeployGate::API::V1::Session).to receive(:show).and_return(results)

      result = DeployGate::API::V1::Session.check(name, token)
      expect(result).to be_truthy
    end

    it "not login" do
      token = 'token'
      name = 'test'
      allow(DeployGate::API::V1::Session).to receive(:show).and_return(nil)

      result = DeployGate::API::V1::Session.check(name, token)
      expect(result).to be_falsey
    end
  end

  describe "#login" do
    it "success" do
      email = 'test@example.com'
      pass = 'examplepass'
      token = 'token'
      name = 'test'

      response = {
          :error => false,
          :because => '',
          :results => {:name => name, :api_token => token}
      }
      stub_request(:post, "#{API_ENDPOINT}/sessions").
          with(:body => {:email => email, :password => pass}).
          to_return(:body => response.to_json)

      results = DeployGate::API::V1::Session.login(email, pass)
      expect(results).to eq ({
                               :error => response[:error],
                               :message => response[:because],
                               :name => name,
                               :token => token
                        })
    end

    it "failed" do
      email = 'test@example.com'
      pass = 'examplepass'
      token = 'token'
      name = 'test'

      response = {
          :error => true,
          :because => 'error message'
      }
      stub_request(:post, "#{API_ENDPOINT}/sessions").
          with(:body => {:email => email, :password => pass}).
          to_return(:body => response.to_json)

      results = DeployGate::API::V1::Session.login(email, pass)
      expect(results).to eq ({
                                :error => response[:error],
                                :message => response[:because]
                            })
    end
  end
end
