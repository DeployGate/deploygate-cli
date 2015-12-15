describe DeployGate::API::V1::Users::App do
  describe "#not_provisoned_udids" do
    it "success" do
      name = 'test'
      package_name = 'package_name'
      platform = 'ios'
      token = 'token'
      provisioned_iphone = {:udid => 'udid', :user_name => 'user_name', :device_name => 'name', :is_provisioned => true}
      not_provisioned_iphone = {:udid => 'udid2', :user_name => 'user_name2', :device_name => 'name2', :is_provisioned => false}
      response = {
          :error => false,
          :because => '',
          :results => [provisioned_iphone, not_provisioned_iphone]
      }
      stub_request(:get, "#{API_ENDPOINT}/users/#{name}/platforms/#{platform}/apps/#{package_name}/udids").
          to_return(:body => response.to_json)

      results = DeployGate::API::V1::Users::App.not_provisioned_udids(token, name, package_name, platform)
      expect(results).to eq({
                                :error => response[:error],
                                :message => response[:because],
                                :results => [not_provisioned_iphone]
                            })
    end
  end
end
