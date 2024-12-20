# github-actions.nvim

Neovim plugin for GitHub actions.

## Installation

example using [Lazy](https://github.com/folke/lazy.nvim) plugin manager

```lua
{
    'disrupted/github-actions.nvim',
    ft = 'yaml.gha',
    opts = {},
}
```

Default configuration (passed as `opts`)

```lua
{}
```

## Features

- custom Treesitter parser for GitHub actions syntax.
