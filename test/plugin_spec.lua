local ntf = require('ntf')
local describe, it, before_each, after_each = ntf.describe, ntf.it, ntf.before_each, ntf.after_each
local assert = ntf.assert

describe('github-actions.nvim lazy loading', function()
  local starts
  local configured
  local saved

  before_each(function()
    starts = {}
    configured = nil
    saved = {
      config = package.loaded['github-actions.config'],
      lsp = package.loaded['github-actions.lsp'],
      entry = package.loaded['github-actions'],
    }

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
    assert.equal(0, #starts)
  end)

  it('starts once on yaml.github and keeps the configured options', function()
    vim.bo.filetype = 'yaml'
    require('github-actions').setup({ marker = 'user' })

    vim.bo.filetype = 'yaml.github'
    require('github-actions').setup()
    assert.equal(1, #starts)
    assert.equal('user', configured.marker)
    assert.is_true(starts[1].lsp.marker)

    require('github-actions').setup({ marker = 'other' })
    assert.equal(1, #starts)
    assert.equal('user', configured.marker)
  end)

  it('registers the custom filetype', function()
    vim.cmd('runtime! ftdetect/github-actions.lua')
    assert.equal('yaml.github', vim.filetype.match({ filename = '/repo/.github/workflows/ci.yml' }))
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
    assert.equal(1, calls)
  end)
end)
