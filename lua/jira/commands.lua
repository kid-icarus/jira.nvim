local api_client = require 'jira.api_client'
local utils = require 'jira.utils'
local M = {}
local config = require 'jira.config'

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
      transition = function(transition_name, issue_id)
        M.transition_issue_name(transition_name, issue_id)
      end,
      create = function(args)
        M.create_issue(args)
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

  local response = api_client.get_issue(issue_id)
  if response.status < 400 then
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
end

-- @param issue_id string - the id of the issue to transition
-- @param transition_name string - the name of the transition to perform
function M.transition_issue_name(transition_name, issue_id)
  transition_name = transition_name or vim.fn.input 'Transition to: '
  issue_id = issue_id or utils.get_issue_id()
  if not issue_id then
    print 'Missing issue id'
    return
  end
  transition_name = transition_name:gsub('_', ' ')
  local response = api_client.transition_issue_name(transition_name, issue_id)
  if response and (response.exit ~= 0 or response.status ~= 204) then
    vim.print 'Error making request'
  end
  if response and response.status == 204 then
    vim.print 'Transitioned issue'
  else
  end
end

local function get_char_input()
  local char = vim.fn.getchar()
  -- if char is escape
  if char == 27 then
    return nil
  end
  return vim.fn.nr2char(char)
end

local function clear_prompt()
  vim.api.nvim_command 'normal! :'
end

-- create a git branch with the issue id
-- @param issue_id string - the issue id to use for the branch
-- @param branch_suffix string - the suffix to append to the branch name
local create_git_branch = function(issue_id, branch_suffix)
  local branch_from = config.get_config().git_trunk_branch
  vim.ui.input({
    prompt = 'Enter branch to create branch from [esc to cancel]: ',
    default = branch_from or 'main',
  }, function(value)
    branch_from = value
  end)

  if not branch_from or branch_from == '' then
    return
  end

  utils.create_git_branch(issue_id, branch_suffix, branch_from)
end

function M.create_issue(issueType)
  if not issueType then
    vim.ui.input({
      prompt = 'Issue type: ',
      default = 'Task',
    }, function(value)
      issueType = value
    end)
  end
  if not issueType or issueType == '' then
    return
  end

  local summary
  vim.ui.input({
    prompt = 'Summary: ',
  }, function(value)
    summary = value
  end)

  if not summary or summary == '' then
    return
  end

  clear_prompt()
  print 'Edit description? (y/N)'
  local res = get_char_input()
  clear_prompt()
  -- if user cancels
  if res == nil then
    return
  end
  local edit_description = false
  if res:match '\r' or res:match '\n' or res:match 'n' or res:match 'N' then
    edit_description = false
  end
  if res:match 'y' or res:match 'Y' then
    edit_description = true
  end

  if not edit_description then
    local r = api_client.create_issue {
      type = issueType,
      summary = summary,
    }
    vim.notify(r.link)
    create_git_branch(r.issue_id, summary)
    return
  end

  local tempfile = vim.fn.tempname()
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(bufnr, tempfile)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'markdown')
  vim.cmd 'split'
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    callback = function()
      local r = api_client.create_issue {
        type = issueType,
        summary = summary,
        descriptionFile = tempfile,
      }
      vim.notify(r.link)
      create_git_branch(r.issue_id, summary)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end,
  })
end

return M
