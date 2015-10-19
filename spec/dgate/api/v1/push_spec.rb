require "spec_helper"

describe Dgate::API::V1::Push do
  describe "#upload" do
    it "success" do
      target_user = 'test'
      token = 'token'
      message = 'message'
      response = {
          :error => false,
          :because => '',
          :results => {
              :name => 'application_name',
              :user => {:name => 'user name'},
              :package_name => 'com.example.package.name',
              :revision => 1,
              :path => '/path/to/app'
          }
      }

      stub_request(:post, "https://deploygate.com/api/users/#{target_user}/apps").
          with(:headers => { 'AUTHORIZATION' => token }).
          to_return(:body => response.to_json)

      results = Dgate::API::V1::Push.upload(test_file_path, target_user, token, message)
      expect(results).to eq ({
                                :error => response[:error],
                                :message => response[:because],
                                :application_name => response[:results][:name],
                                :owner_name => response[:results][:user][:name],
                                :package_name => response[:results][:package_name],
                                :revision => response[:results][:revision],
                                :web_url => Dgate::API::V1::Base::BASE_URL + response[:results][:path]
                            })
    end

    it "failed" do
      target_user = 'test'
      token = 'token'
      message = 'message'
      response = {
          :error => true,
          :because => 'error message'
      }

      stub_request(:post, "https://deploygate.com/api/users/#{target_user}/apps").
          with(:headers => { 'AUTHORIZATION' => token }).
          to_return(:body => response.to_json)

      results = Dgate::API::V1::Push.upload(test_file_path, target_user, token, message)
      expect(results).to eq ({:error => response[:error], :message => response[:because]})
    end
  end
end
