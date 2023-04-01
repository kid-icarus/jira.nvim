local api_client = require 'jira.api_client'
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
  api_client.get_issue(issue_id, function(err, response)
    if err then
      print('Error: ' .. err)
      return
    end
    if response.code < 400 then
      vim.schedule(function()
        local data = vim.fn.json_decode(response.body)
        local desc = {}
        for _, v in ipairs(data.fields.description.content) do
          for _, v2 in ipairs(v.content) do
            if v2.type == 'text' then
              desc[#desc + 1] = v2.text
            end
          end
        end
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_option(buf, 'readonly', false)
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, desc)
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.cmd 'vsplit'
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
      end)
    else
      print('Non 200 response: ' .. response.code)
    end
  end)
end

return M
