require "webmock/rspec"
require "json"

require "dgate"

RSpec.configure do |config|
end

API_ENDPOINT = "https://deploygate.com/api"
SPEC_FILE_PATH = File.dirname(__FILE__)

def test_file_path
  File.join(SPEC_FILE_PATH, 'DeployGateSample.apk')
end
