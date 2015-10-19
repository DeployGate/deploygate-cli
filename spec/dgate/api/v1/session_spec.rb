describe Dgate::API::V1::Session do
  describe "#check" do
    it "logined" do
      token = 'token'
      name = 'test'
      response = {
          :error => false,
          :because => '',
          :results => {:name => name}
      }
      stub_request(:get, "#{API_ENDPOINT}/sessions/user").
          with(:headers => { 'AUTHORIZATION' => token }).
          to_return(:body => response.to_json)


      result = Dgate::API::V1::Session.check(name, token)
      expect(result).to be_truthy
    end

    it "not login" do
      token = 'token'
      name = 'test'
      response = {
          :error => true,
          :because => 'error message'
      }
      stub_request(:get, "#{API_ENDPOINT}/sessions/user").
          with(:headers => { 'AUTHORIZATION' => token }).
          to_return(:body => response.to_json)

      result = Dgate::API::V1::Session.check(name, token)
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

      results = Dgate::API::V1::Session.login(email, pass)
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

      results = Dgate::API::V1::Session.login(email, pass)
      expect(results).to eq ({
                                :error => response[:error],
                                :message => response[:because]
                            })
    end
  end
end
