local transitions = require('jira.pickers').transitions

return require('telescope').register_extension {
  exports = {
    transitions = transitions,
  },
}
