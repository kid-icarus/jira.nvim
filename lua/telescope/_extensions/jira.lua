local transitions = require('jira.pickers.telescope').transitions

return require('telescope').register_extension {
  exports = {
    transitions = transitions,
  },
}
