require "webmock/rspec"
require "json"

require "dgate"

API_ENDPOINT = "https://deploygate.com/api"

def test_file_path
  File.join(File.dirname(__FILE__), 'DeployGateSample.apk')
end
