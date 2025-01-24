local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values
local api_client = require 'jira.api_client'

local M = {}

local transitions = function(opts)
  opts = opts or {}
  local results = api_client.get_transitions()
  pickers
    .new(opts, {
      prompt_title = 'Transitions',
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
          }
        end,
      },
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          api_client.transition_issue(selection.value.id)
        end)
        return true
      end,
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

M.transitions = transitions

return M
