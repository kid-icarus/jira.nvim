local utils = require 'jira.utils'
local config = require 'jira.config'
local curl = require 'plenary.curl'
local _, Job = pcall(require, 'plenary.job')

local M = {}
local transition_cache = {}

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
  issue_id = utils.get_issue_id(issue_id)
  assert(issue_id, 'Missing issue id')
  if transition_cache[issue_id] then
    return transition_cache[issue_id]
  end
  local url = get_base_url() .. '/issue/' .. issue_id .. '/transitions'
  local response = curl.get(url, {
    headers = get_auth_headers(),
  })
  if response.exit ~= 0 then
    vim.print 'Error getting transitions'
  end
  if response.status ~= 200 then
    print('Error getting transitions: ' .. response.body)
    return
  end
  local result = vim.fn.json_decode(response.body)
  transition_cache[issue_id] = result.transitions
  return result.transitions
end

-- Gets the transition id for the given transition name and then transitions the issue
-- Helpful for when you don't know the transition id
M.transition_issue_name = function(transition_name, issue_id)
  assert(transition_name, 'Missing transition name')
  issue_id = utils.get_issue_id(issue_id)
  local transitions = M.get_transitions(issue_id)
  local transition_id
  for _, transition in ipairs(transitions) do
    if transition.name == transition_name then
      transition_id = transition.id
      break
    end
  end
  assert(transition_id, 'Transition not found: ' .. transition_name)
  return M.transition_issue(transition_id, issue_id)
end

-- Transitions the issue to the given transition id
M.transition_issue = function(transition_id, issue_id)
  assert(transition_id, 'Missing transition id')
  issue_id = utils.get_issue_id(issue_id)
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

-- Creates an issue with the given type, summary, and optional description file path
-- @param issue table - the issue to create
-- @param issue.type string - the type of the issue
-- @param issue.summary string - the summary of the issue
-- @param issue.descriptionFile string - the path to the file containing the description
-- @return table - the issue id and link
-- e.g. { issue_id = 'ABC-1234', link = 'https://blah.atlassian.net/ABC-1234' }
M.create_issue = function(issue)
  local type = issue.type
  local summary = issue.summary
  local descriptionFilePath = issue.descriptionFile
  assert(type, 'Missing issue type')
  assert(summary, 'Missing issue summary')

  local args = { 'issue', 'create', '-t', type, '-s', summary }
  if descriptionFilePath then
    table.insert(args, '-T')
    table.insert(args, descriptionFilePath)
  end

  local job = Job:new {
    enable_recording = true,
    interactive = false,
    command = 'jira',
    args = args,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.nofity('Error creating issue', vim.log.levels.ERROR)
      end
    end,
  }
  job:sync()
  local lines = job:result()
  -- last line is the issue id
  -- e.g. 'Issue created: ABC-1234'
  -- extract the issue id:
  -- 'ABC-1234'
  local issue_id = lines[#lines]:match '([A-Z]+%-[0-9]+)'
  return { issue_id = issue_id, link = lines[#lines] }
end

return M
