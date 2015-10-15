require "commander/import"
require "json"
require "httpclient"
require "io/console"

module Dgate
end

require "dgate/command_builder"
require "dgate/api/v1/base"
require "dgate/api/v1/session"
require "dgate/commands/init"
require "dgate/commands/logout"
require "dgate/session"
require "dgate/version"
