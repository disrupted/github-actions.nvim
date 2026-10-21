describe('github-actions.lsp', function()
  local system
  local lsp

  before_each(function()
    system = require('github-actions.system')
    lsp = require('github-actions.lsp')
  end)

  describe('system.run', function()
    it('completes asynchronously on the main loop', function()
      local completed = false
      system.run({ 'sh', '-c', 'sleep 0.05; printf done' }, { text = true }, function(out)
        assert.is_false(vim.in_fast_event())
        assert.same(0, out.code)
        assert.same('done', out.stdout)
        completed = true
      end)
      assert.is_false(completed, 'system.run must return before completion')
      assert.is_true(vim.wait(2000, function()
        return completed
      end))
    end)
  end)

  describe('setup', function()
    local original_config
    local original_run
    local starts
    local pending

    before_each(function()
      original_config = lsp.config
      original_run = system.run
      starts = {}
      pending = nil

      lsp.config = function(config)
        starts[#starts + 1] = config
      end
      system.run = function(cmd, opts, callback)
        assert.same('gh', cmd[1])
        assert.same('repo', cmd[2])
        assert.same(vim.fs.root(0, '.git'), opts.cwd)
        pending = callback
      end
    end)

    after_each(function()
      lsp.config = original_config
      system.run = original_run
    end)

    local function finish()
      pending({
        code = 0,
        stdout = vim.json.encode({
          owner = { login = 'owner' },
          name = 'repo',
          isInOrganization = false,
        }),
      })
    end

    it('waits for the token and repository discovery before starting', function()
      local token_callback
      local config = {
        token_provider = function(callback)
          token_callback = callback
        end,
        lsp = { init_options = {} },
      }

      lsp.setup(config)
      assert.same(0, #starts)
      assert.is_nil(pending)

      token_callback('github_pat_example\n')
      assert.is_true(vim.wait(1000, function()
        return pending ~= nil
      end))
      assert.same(0, #starts, 'must wait for repository discovery')

      finish()
      assert.same(1, #starts)
      assert.same('github_pat_example', starts[1].init_options.sessionToken)
      assert.same('owner', starts[1].init_options.repos[1].owner)
      assert.is_nil(config.lsp.init_options.repos, 'must not mutate shared options')
    end)

    it('discovers the repository even without a token provider', function()
      lsp.setup({ token_provider = false, lsp = { init_options = {} } })
      assert.is_truthy(pending)
      assert.same(0, #starts)

      finish()
      assert.same(1, #starts)
    end)

    it('respects explicit repository contexts', function()
      lsp.setup({ token_provider = false, lsp = { init_options = { repos = {} } } })
      assert.is_nil(pending)
      assert.same(1, #starts)
    end)

    it('does not initialize without repository context', function()
      local errors = {}
      local utils = require('github-actions.utils')
      local original_error = utils.error
      utils.error = function(message)
        errors[#errors + 1] = message
      end

      local ok = pcall(function()
        lsp.setup({ token_provider = false, lsp = {} })
        pending({ code = 1, stderr = 'discovery failed' })
        assert.same(0, #starts)
        assert.same(1, #errors)

        pending({ code = 0, stdout = 'invalid json' })
        assert.same(0, #starts)
        assert.same(2, #errors)
      end)

      utils.error = original_error
      assert.is_true(ok)
    end)
  end)
end)
