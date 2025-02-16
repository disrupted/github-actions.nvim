# github-actions.nvim

Neovim plugin for GitHub Actions.

## Requirements

- `gh` CLI installed and authenticated. (please check `gh auth status`)

## Installation

example using [Lazy](https://github.com/folke/lazy.nvim) plugin manager

```lua
{
    'disrupted/github-actions.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'gregorias/coop.nvim', -- used for async config with GitHub token provider
        'williamboman/mason.nvim', -- optional
    },
    ft = 'yaml.github',
    ---@module 'github-actions.config'
    ---@type github_actions.Opts
    opts = {},
}
```

Default configuration (passed as `opts`)

```lua
{}
```

## Features

- configure LSP for GitHub Actions. Some language server features require a GitHub access token. The default token provider retrieves it from the `gh` CLI. You can override the token provider if you prefer to retrieve it from your password manager instead.
- custom Treesitter parser for GitHub Actions syntax.
