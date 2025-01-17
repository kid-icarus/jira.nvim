# jira.nvim

A neovim interface to Jira.

## Goals

- Maximalism - an all-encompassing interface to Jira vs. tiny lib.
- Integration - integrate with popular neovim plugins for an enhanced UX.
    Telescope, etc.

## Non-goals

Vim compatibility.

## 🚨 Currently a work in progress!

Please follow along with the [initial release discussion](https://github.com/kid-icarus/jira.nvim/discussions/1) for an overview of the project's status.

## ⚡️ Requirements

- Instead of using the Jira API directly in all cases, this plugin leverages the [jira-cli tool](https://github.com/ankitpokhrel/jira-cli) to interact with Jira. You'll need to install it and configure it with your Jira credentials in order to use some of the features of this plugin.

## 📦 Installation

Use your favourite plugin manager to install it. eg:

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'kid-icarus/jira.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  }
  config = function ()
    require'jira'.setup() -- see configuration section
  end
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'kid-icarus/jira.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {}, -- see configuration section
}
```

## ⚙️  Configuration

First of all, you'll need to create a [personal Jira API
token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

By default, jira.nvim is configured a to use few environment variables you'll need to set them or override them in setup order to use the plugin:

- `JIRA_USER` - Your atlassian username
- `JIRA_API_TOKEN` - Your personal API token 
- `JIRA_DOMAIN` - The domain of your Jira instance, i.e. `example.atlassian.net`

```lua
require'jira'.setup({
  jira_api = {
    domain = vim.env.JIRA_DOMAIN,
    username = vim.env.JIRA_USER,
    token = vim.env.JIRA_API_TOKEN
  },
  use_git_branch_issue_id = true,
  git_trunk_branch = 'main', -- The main branch of your project
  git_branch_prefix = 'feature/', -- The prefix for your feature branches
})
```

## 🤖 Commands

There is only an Jira <object> <action> [arguments] command.

| Object | Action | Description |
|---|---|---|
| issue | view [issue_id] | View the given issue, if none provided it will attempt to extract one out of the current git branch (disabled via `use_git_branch_issue_id`), else falls back to a prompt |
|   |  transition [transition_name] [issue_id] | Transition the ticket to a given status. Will attempt to extract issue ID from git branch, and will prompt if no options given
|   |  create | Create a new issue. Will prompt for all required fields. It will also prompt you to create a branch with the created issue ID in the name.

Additionally, the transition command has a Telescope picker.

`:Telescope jira transitions`

## Mappings

There are no default mappings, but you can create your own. Here's an example:

```lua
local t = require 'telescope'
vim.keymap.set('n', '<leader>jv', '<cmd>Jira issue view<cr>', {})
vim.keymap.set('n', '<leader>jt', t.extensions.jira.transitions, {})
vim.keymap.set('n', '<leader>jc', '<cmd>Jira issue create<cr>', {})
```
