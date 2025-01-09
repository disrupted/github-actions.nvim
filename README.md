# github-actions.nvim

Neovim plugin for GitHub Actions.

## Installation

example using [Lazy](https://github.com/folke/lazy.nvim) plugin manager

```lua
{
    'disrupted/github-actions.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim', -- optional
    },
    ft = 'yaml.github',
    opts = {},
}
```

Default configuration (passed as `opts`)

```lua
{}
```

## Features

- custom Treesitter parser for GitHub Actions syntax.
