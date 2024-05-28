local M = {}

M.defaults = {
  jira_api = {
    domain = vim.env.JIRA_DOMAIN,
    username = vim.env.JIRA_USER,
    token = vim.env.JIRA_API_TOKEN,
  },
  use_git_branch_issue_id = true,
  git_branch_prefix = 'feature/',
  git_trunk_branch = 'main',
}

local config = {}

function M.get_config()
  return config or M.defaults
end

function M.set_current_issue(issue_id)
  config.current_issue = issue_id
end

function M.setup(user_config)
  user_config = user_config or {}
  config = vim.tbl_deep_extend('force', M.defaults, user_config)

  return config
end

return M
