## jira.nvim

A neovim interface to Jira.

## ⚡️ Requirements

- Install [http.nvim](https://github.com/jcdickinson/http.nvim)

## 📦 Installation

Use your favourite plugin manager to install it. eg:

```lua
use {
  'kid-icarus/jira.nvim',
  requires = {
    'jcdickinson/http.nvim',
  }
}
```

## ⚙️  Configuration

First of all, you'll need to create a [personal Jira API
token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

There are a few environment variables you'll need to set in order to use the
plugin:

- `JIRA_USER` - Your atlassian username
- `JIRA_API_TOKEN` - Your personal API token 
- `JIRA_DOMAIN` - The domain of your Jira instance, i.e. `example.atlassian.net`

## Goals

- Maximalism - an all-encompassing interface to Jira vs. tiny lib.
- Integration - integrate with popular neovim plugins for an enhanced UX.
    Telescope, etc.

## Non-goals

Vim compatibility.
