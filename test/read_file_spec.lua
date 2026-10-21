local ntf = require('ntf')
local describe, it, before_each, after_each = ntf.describe, ntf.it, ntf.before_each, ntf.after_each
local assert = ntf.assert

describe('actions/readFile handler', function()
  local handler
  local path
  local uri

  before_each(function()
    local config = require('github-actions.config')
    config.setup({ token_provider = false })
    handler = config.config.lsp.handlers['actions/readFile']
    path = vim.fn.tempname() .. ' with spaces.yaml'
    uri = vim.uri_from_fname(path)
  end)

  after_each(function()
    vim.fn.delete(path)
  end)

  it('returns JSON null for a missing file', function()
    local result, err = handler(nil, { path = uri })
    assert.is_true(result == vim.NIL)
    assert.is_nil(err)
    assert.equal('{"result":null}', vim.json.encode({ result = result }))
  end)

  it('returns the file contents', function()
    local file = io.open(path, 'wb')
    assert.truthy(file)
    file:write('name: Test\n')
    file:close()

    local result, err = handler(nil, { path = uri })
    assert.equal('name: Test\n', result)
    assert.is_nil(err)
  end)

  it('returns an empty string for an empty file', function()
    local file = io.open(path, 'wb')
    assert.truthy(file)
    file:close()

    local result, err = handler(nil, { path = uri })
    assert.equal('', result)
    assert.is_nil(err)
  end)

  it('rejects invalid params', function()
    for _, params in ipairs({
      false,
      {},
      { path = 42 },
      { path = 'https://example.com/action.yml' },
    }) do
      local result, err = handler(nil, params)
      assert.is_nil(result)
      assert.equal(vim.lsp.protocol.ErrorCodes.InvalidParams, err.code)
    end

    local result, err = handler(nil, nil)
    assert.is_nil(result)
    assert.equal(vim.lsp.protocol.ErrorCodes.InvalidParams, err.code)
  end)
end)
