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

M.get_transitions = function(issue_id, callback)
  local url = get_base_url() .. '/issue/' .. issue_id .. '/transitions'
  http.request {
    http.methods.GET,
    url,
    nil,
    nil,
    headers = get_auth_headers(),
    callback = callback,
  }
end

-- Gets the transition id for the given transition name and then transitions the issue
-- Helpful for when you don't know the transition id
M.transition_issue_name = function(issue_id, transition_name, callback)
  M.get_transitions(issue_id, function(err, response)
    if err then
      print('Error getting transitions: ' .. err)
      return
    end
    if response.code >= 400 then
      print('Error getting transitions: ' .. response.body)
      return
    end
    vim.schedule(function()
      local result = vim.fn.json_decode(response.body)
      if err then
        print('Error getting transitions: ' .. err)
        return
      end
      local transitions = result.transitions
      for _, transition in ipairs(transitions) do
        if transition.name == transition_name then
          M.transition_issue(issue_id, transition.id, callback)
          return
        end
      end
      assert(transition_name, 'Transition not found: ' .. transition_name)
    end)
  end)
end

-- Transitions the issue to the given transition id
M.transition_issue = function(issue_id, transition_id, callback)
  local url = get_base_url() .. '/issue/' .. issue_id .. '/transitions'
  local body = vim.json.encode {
    transition = {
      id = transition_id,
    },
  }
  http.request {
    http.methods.POST,
    url,
    body,
    nil,
    headers = get_auth_headers(),
    callback = callback,
  }
end

return M
