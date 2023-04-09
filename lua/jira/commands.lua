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
      transition = function(issue_id, transition_name)
        M.transition_issue_name(issue_id, transition_name)
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
  issue_id = issue_id or utils.get_issue_id()
  if not issue_id then
    print 'Missing issue id'
    return
  end

  api_client.get_issue(issue_id, function(err, response)
    if err then
      print('Error: ' .. err)
      return
    end
    if response.code < 400 then
      vim.schedule(function()
        local data = vim.fn.json_decode(response.body)
        local summary = data.fields.summary
        local desc = utils.convert_adf_to_markdown(data.fields.description)
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_option(buf, 'readonly', false)
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nowrite')
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { '# ' .. summary, '' })
        vim.api.nvim_buf_set_lines(buf, -1, -1, true, vim.split(desc, '\n'))
        vim.api.nvim_buf_set_lines(buf, -1, -1, true, { '', '## Comments', '' })
        if data.fields.comment.total == 0 then
          vim.api.nvim_buf_set_lines(buf, -1, -1, true, { 'No comments', '' })
        else
          for _, comment in ipairs(data.fields.comment.comments) do
            local author = comment.author.displayName
            local timestamp = comment.updated
            local body = utils.convert_adf_to_markdown(comment.body)
            vim.api.nvim_buf_set_lines(buf, -1, -1, true, { '# ' .. author .. ' ' .. timestamp, '' })
            vim.api.nvim_buf_set_lines(buf, -1, -1, true, vim.split(body, '\n'))
          end
        end
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

-- @param issue_id string - the id of the issue to transition
-- @param transition_name string - the name of the transition to perform
function M.transition_issue_name(issue_id, transition_name)
  issue_id = issue_id or utils.get_issue_id()
  if not issue_id then
    print 'Missing issue id'
    return
  end
  transition_name = transition_name or vim.fn.input 'Transition name: '
  transition_name = transition_name:gsub('_', ' ')
  api_client.transition_issue_name(issue_id, transition_name, function(err, response)
    if err then
      print('Error: ' .. err)
      return
    end
    if response.code < 400 then
      print('Transitioned issue ' .. issue_id .. ' to ' .. transition_name)
    else
      print('Non 200 response: ' .. response.code)
    end
  end)
end

return M
