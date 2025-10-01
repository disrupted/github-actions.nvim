# github-actions.nvim

Neovim plugin for GitHub Actions.

## Features

- configure LSP for GitHub Actions.

## Installation

example using [Lazy](https://github.com/folke/lazy.nvim) plugin manager

```lua
{
    'disrupted/github-actions.nvim',
    ft = 'yaml.github',
    ---@module 'github-actions.config'
    ---@type github_actions.Opts
    opts = {},
}
```

## Configuration

### Token provider

Some language server features require a GitHub access token.

The default token provider retrieves it from the `gh` CLI. Make sure it's installed and authenticated (check `gh auth status`).

If you want to retrieve it from a different CLI, such as a password mananger, you can override the token provider.

Here's an example for `op` (1Password CLI):

```lua
opts = {
  token_provider = function(callback)
    require('github-actions.lsp.token_provider').system({
      'op',
      'read',
      'op://Work/GitHub/Access Token/xg7h2j4k9m1qv8z3r5w8n2p6s0',
    }, callback)
  end,
}
```

You can also define a custom token provider function, e.g. to retrieve it from the environment.

```lua
opts = {
  token_provider = function(callback)
    callback(vim.env.GITHUB_TOKEN)
  end,
}
```

## Notes

to add Treesitter parser for GitHub Actions syntax take a look at [gh-actions.nvim](https://github.com/Hdoc1509/gh-actions.nvim)
