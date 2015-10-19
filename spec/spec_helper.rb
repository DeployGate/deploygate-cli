require "webmock/rspec"
require "json"


RSpec.configure do |config|
end

require "dgate"

def test_file_path
  File.join(File.dirname(__FILE__), 'DeployGateSample.apk')
end
