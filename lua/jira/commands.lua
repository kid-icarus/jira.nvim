local api_client = require 'jira.api_client'
local utils = require 'jira.utils'
local M = {}

M.setup = function()
  vim.api.nvim_create_user_command('Jira', function(opts)
    require('jira.commands').jira(unpack(opts.fargs))
  end, { nargs = '*' })

  -- supported commands
  M.commands = {
    issue = {
      view = function(issue_id)
        M.view_issue(issue_id)
      end,
    },
  }
end

function M.jira(object, action, ...)
  if not object then
    print 'Missing arguments'
    return
  end
  local o = M.commands[object]
  if type(o) == 'function' then
    if object == 'search' then
      o(action, ...)
    else
      o(...)
    end
    return
  end

  local a = o[action]
  if not a then
    print('Incorrect action: ' .. action)
    return
  else
    a(...)
  end
end

function M.view_issue(issue_id)
  local config = require('jira.config').get_config()
  if not issue_id then
    if config.use_git_branch_issue_id then
      issue_id = M.get_issue_id_from_git_branch()
    end
  end

  -- fallback to user input
  if not issue_id then
    vim.ui.input({
      prompt = 'Issue ID: ',
    }, function(id)
      issue_id = id
    end)
  end

  api_client.get_issue(issue_id, function(err, response)
    if err then
      print('Error: ' .. err)
      return
    end
    if response.code < 400 then
      vim.schedule(function()
        local data = vim.fn.json_decode(response.body)
        local desc = utils.convert_adf_to_markdown(data.fields.description)
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_option(buf, 'readonly', false)
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nowrite')
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(desc, '\n', true))
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
        vim.cmd 'vsplit'
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
      end)
    else
      print('Non 200 response: ' .. response.code)
    end
  end)
end

-- extract issue id from branch name
-- e.g. feature/ABC-1234
-- e.g. ABC-1234
M.get_issue_id_from_git_branch = function()
  local branch = vim.fn.system 'git rev-parse --abbrev-ref HEAD'
  local issue_id = string.match(branch, '([A-Z]+%-[0-9]+)')
  return issue_id
end

return M
