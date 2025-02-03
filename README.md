# github-actions.nvim

Neovim plugin for GitHub Actions.

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
    opts = {
        -- NOTE: some language server features require a GitHub Access Token. Implement this async function to retrieve it.
        token_provider = function()
            -- it is recommended to retrieve the token from a password manager
            return 'ghp_........'
        end,
    },
}
```

Default configuration (passed as `opts`)

```lua
{}
```

## Features

- custom Treesitter parser for GitHub Actions syntax.
- configure LSP for GitHub Actions.
