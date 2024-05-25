local utils = require 'jira.utils'
local config = require 'jira.config'
local curl = require 'plenary.curl'

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

M.get_issue = function(issue_id)
  local url = get_base_url() .. '/issue/' .. issue_id
  return curl.get(url, {
    headers = get_auth_headers(),
  })
end

M.get_transitions = function(issue_id)
  local url = get_base_url() .. '/issue/' .. issue_id .. '/transitions'
  return curl.get(url, {
    headers = get_auth_headers(),
  })
end

-- Gets the transition id for the given transition name and then transitions the issue
-- Helpful for when you don't know the transition id
M.transition_issue_name = function(issue_id, transition_name)
  local response = M.get_transitions(issue_id)
  if response.exit ~= 0 then
    vim.print 'Error getting transitions'
  end
  if response.status ~= 200 then
    print('Error getting transitions: ' .. response.body)
    return
  end

  local result = vim.fn.json_decode(response.body)
  local transitions = result.transitions
  local transition_id
  for _, transition in ipairs(transitions) do
    if transition.name == transition_name then
      transition_id = transition.id
      break
    end
  end
  assert(transition_id, 'Transition not found: ' .. transition_name)
  return M.transition_issue(issue_id, transition_id)
end

-- Transitions the issue to the given transition id
M.transition_issue = function(issue_id, transition_id)
  assert(issue_id, 'Missing issue id')
  assert(transition_id, 'Missing issue id')
  local url = get_base_url() .. '/issue/' .. issue_id .. '/transitions'
  local body = vim.json.encode {
    transition = {
      id = transition_id,
    },
  }

  return curl.post(url, {
    headers = get_auth_headers(),
    body = body,
  })
end

return M
