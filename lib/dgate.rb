require "commander/import"
require "json"
require "httpclient"
require "io/console"
require "rbconfig"

module Dgate
end

require "dgate/command_builder"
require "dgate/api/v1/base"
require "dgate/api/v1/session"
require "dgate/api/v1/push"
require "dgate/commands/init"
require "dgate/commands/logout"
require "dgate/commands/deploy"
require "dgate/commands/deploy/push"
require "dgate/session"
require "dgate/deploy"
require "dgate/version"
