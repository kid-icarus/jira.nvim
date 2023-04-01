local http = require("http")

local Jira = {}

local dic = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
-- encoding
local function b64(data)
  return (
      (data:gsub(".", function(x)
        local r, b = "", x:byte()
        for i = 8, 1, -1 do
          r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
        end
        return r
      end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then
          return ""
        end
        local c = 0
        for i = 1, 6 do
          c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
        end
        return dic:sub(c + 1, c + 1)
      end) .. ({ "", "==", "=" })[#data % 3 + 1]
      )
end

Jira.get_issues = function(issue)
  http.request({
    http.methods.GET,
    "https://" .. vim.env.JIRA_DOMAIN .. "/rest/api/3/issue/" .. issue,
    nil,
    nil,
    headers = {
      ["content-type"] = "application/json",
      Authorization = "Basic " .. b64(vim.env.JIRA_USER .. ":" .. vim.env.JIRA_API_TOKEN),
    },
    callback = function(err, response)
      if err then
        print("Error: " .. err)
        return
      end
      if response.code < 400 then
        vim.schedule(function()
          local data = vim.fn.json_decode(response.body)
          P(data.fields.description)
          -- local issue = data.key
          -- local summary = data.fields.summary
          local desc = {}
          for _, v in ipairs(data.fields.description.content) do
            for _, v2 in ipairs(v.content) do
              if v2.type == "text" then
                desc[#desc + 1] = v2.text
              end
            end
          end
          P(desc)
          -- local status = data.fields.status.name
          -- local assignee = data.fields.assignee.displayName
          -- local reporter = data.fields.reporter.displayName
          -- local created = data.fields.created
          -- local updated = data.fields.updated
          -- local issue_type = data.fields.issuetype.name
          -- local priority = data.fields.priority.name
          -- local project = data.fields.project.name
          -- local url = "https://" .. vim.env.JIRA_DOMAIN .. "/browse/" .. issue
          local buf = vim.api.nvim_create_buf(true, false)
          vim.api.nvim_buf_set_option(buf, "readonly", false)
          -- vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
          -- vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
          -- vim.api.nvim_buf_set_option(buf, "filetype", "jira")
          -- vim.api.nvim_buf_set_option(buf, 'swapfile', false)
          vim.api.nvim_buf_set_option(buf, "modifiable", true)
          vim.api.nvim_buf_set_lines(
            buf,
            0,
            -1,
            true,
            desc
          -- "Issue: " .. issue,
          -- "Summary: " .. summary,
          -- "Description: " .. desc,
          -- "Status: " .. status,
          -- "Assignee: " .. assignee,
          -- "Reporter: " .. reporter,
          -- "Created: " .. created,
          -- "Updated: " .. updated,
          -- "Issue Type: " .. issue_type,
          -- "Priority: " .. priority,
          -- "Project: " .. project,
          -- "URL: " .. url,
          )

          vim.api.nvim_buf_set_option(buf, "modifiable", false)
          vim.cmd("vsplit")
          local win = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_buf(win, buf)
          -- vim.api.nvim_command("setlocal buftype=nofile bufhidden=wipe swapfile=false")
          -- vim.api.nvim_command("setlocal filetype=jira")
          -- vim.api.nvim_command("setlocal nomodifiable")
          -- vim.api.nvim_command("setlocal bufhidden=wipe")
          -- vim.api.nvim_command("setlocal swapfile=false")
          -- vim.api.nvim_command("setlocal buftype=nofile")
          -- vim.api.nvim_command("setlocal bufhidden=wipe")
        end)
      else
        print("Non 200 response: " .. response.code)
      end
    end,
  })
end

return Jira
