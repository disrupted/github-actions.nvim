describe('github-actions.nvim lazy loading', function()
  local starts
  local configured
  local saved = {}

  before_each(function()
    starts = {}
    configured = nil
    saved.config = package.loaded['github-actions.config']
    saved.lsp = package.loaded['github-actions.lsp']
    saved.entry = package.loaded['github-actions']

    -- Stub the heavy dependencies.
    package.loaded['github-actions.config'] = {
      config = { lsp = { marker = true } },
      setup = function(opts)
        configured = opts
      end,
    }
    package.loaded['github-actions.lsp'] = {
      setup = function(config)
        starts[#starts + 1] = config
      end,
    }
    package.loaded['github-actions'] = nil
  end)

  after_each(function()
    package.loaded['github-actions.config'] = saved.config
    package.loaded['github-actions.lsp'] = saved.lsp
    package.loaded['github-actions'] = saved.entry
    pcall(vim.api.nvim_del_augroup_by_name, 'github_actions_nvim')
  end)

  it('does not start the LSP outside yaml.github', function()
    vim.bo.filetype = 'yaml'
    require('github-actions').setup({ marker = 'user' })
    assert.same(0, #starts)
  end)

  it('starts once on yaml.github and keeps the configured options', function()
    vim.bo.filetype = 'yaml'
    require('github-actions').setup({ marker = 'user' })

    vim.bo.filetype = 'yaml.github'
    require('github-actions').setup()
    assert.same(1, #starts)
    assert.same('user', configured.marker)
    assert.same(true, starts[1].lsp.marker)

    require('github-actions').setup({ marker = 'other' })
    assert.same(1, #starts)
    assert.same('user', configured.marker)
  end)

  it('registers the custom filetype', function()
    vim.cmd('runtime! ftdetect/github-actions.lua')
    assert.same('yaml.github', vim.filetype.match({ filename = '/repo/.github/workflows/ci.yml' }))
  end)

  it('lazy-loads the plugin on FileType', function()
    local calls = 0
    package.loaded['github-actions'] = {
      setup = function()
        calls = calls + 1
      end,
    }

    vim.cmd('runtime! plugin/github-actions.lua')
    vim.api.nvim_exec_autocmds('FileType', { pattern = 'yaml.github' })
    assert.same(1, calls)
  end)
end)
