local http = require 'http'
local utils = require 'jira.utils'
local config = require 'jira.config'

local M = {}

local get_auth_headers = function()
  local jira_api_config = config.get_config().jira_api
  return {
    ['content-type'] = 'application/json',
    Authorization = 'Basic ' .. utils.b64encode(jira_api_config.username .. ':' .. jira_api_config.token),
  }
end

local get_base_url = function()
  local jira_api_config = config.get_config().jira_api
  return 'https://' .. jira_api_config.domain .. '/rest/api/3'
end

M.get_issue = function(issue_id, callback)
  local url = get_base_url() .. '/issue/' .. issue_id
  http.request {
    http.methods.GET,
    url,
    nil,
    nil,
    headers = get_auth_headers(),
    callback = callback,
  }
end

return M
