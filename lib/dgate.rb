require "commander"
require "json"
require "httpclient"
require "io/console"
require "rbconfig"
require "color_echo"

module Dgate
end

require "dgate/api/v1/base"
require "dgate/api/v1/session"
require "dgate/api/v1/push"
require "dgate/command_builder"
require "dgate/commands/init"
require "dgate/commands/logout"
require "dgate/commands/deploy"
require "dgate/commands/deploy/push"
require "dgate/config"
require "dgate/session"
require "dgate/deploy"
require "dgate/message/error"
require "dgate/message/success"
require "dgate/version"
