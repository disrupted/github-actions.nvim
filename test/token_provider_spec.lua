local ntf = require('ntf')
local describe, it, before_each, after_each = ntf.describe, ntf.it, ntf.before_each, ntf.after_each
local assert = ntf.assert

describe('github-actions.lsp.token_provider', function()
  local system
  local provider
  local utils
  local original_run
  local original_error
  local completion

  before_each(function()
    system = require('github-actions.system')
    provider = require('github-actions.lsp.token_provider')
    utils = require('github-actions.utils')
    original_run = system.run
    original_error = utils.error
    completion = nil

    system.run = function(cmd, opts, callback)
      assert.same({ 'gh', 'auth', 'token' }, cmd)
      assert.is_true(opts.text)
      completion = callback
    end
  end)

  after_each(function()
    system.run = original_run
    utils.error = original_error
  end)

  it('returns a validated token', function()
    local token
    provider.gh(function(value)
      token = value
    end)
    assert.is_nil(token)

    completion({ code = 0, stdout = 'github_pat_example\n' })
    assert.equal('github_pat_example', provider.validate(token))
    assert.is_false(pcall(provider.validate, '  '))
  end)

  it('reports an error when gh fails', function()
    local message
    utils.error = function(value)
      message = value
    end

    local token
    provider.gh(function(value)
      token = value
    end)
    completion({ code = 1, stderr = 'not authenticated' })

    assert.is_nil(token)
    assert.truthy(message:find('not authenticated', 1, true))
  end)
end)
