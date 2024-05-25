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

- Install [http.nvim](https://github.com/jcdickinson/http.nvim)

## 📦 Installation

Use your favourite plugin manager to install it. eg:

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'kid-icarus/jira.nvim',
  requires = {
    'jcdickinson/http.nvim',
  }
  config = function ()
    require'jira'.setup() -- see configuration section
  end
}
```

Using [lazygit.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'kid-icarus/jira.nvim',
  dependencies = {
    'jcdickinson/http.nvim',
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
})
```

## 🤖 Commands

There is only an Jira <object> <action> [arguments] command.

| Object | Action | Description |
|---|---|---|
| issue | view [issue_id] | View the given issue, if none provided it will attempt to extract one out of the current git branch (disabled via `use_git_branch_issue_id`), else falls back to a prompt |
|   |  transition [issue_id] [transition_name] | Transition the ticket to a given status. Will attempt to extract issue ID from git branch, and will prompt if no options given

