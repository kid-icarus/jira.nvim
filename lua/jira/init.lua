local config = require 'jira.config'
local commands = require 'jira.commands'

local M = {}

function M.setup(user_config)
  config.setup(user_config or {})
  commands.setup()
end

return M
