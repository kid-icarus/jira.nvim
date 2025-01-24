local picker = require 'snacks.picker'
local api_client = require 'jira.api_client'

local M = {}

local transitions = function()
  local results = api_client.get_transitions()
  picker.select(results, {
    prompt = 'Transitions',
    format_item = function(item)
      return item.name
    end,
  }, function(selection)
    if selection then
      api_client.transition_issue(selection.id)
    end
  end)
end

M.transitions = transitions

return M
