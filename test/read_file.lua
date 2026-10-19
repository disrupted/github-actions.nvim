-- Run with: nvim --headless -u NONE -l test/read_file.lua
vim.opt.rtp:prepend(vim.uv.cwd())
local config = require('github-actions.config')
config.setup({ token_provider = false })
local handler = config.config.lsp.handlers['actions/readFile']
local path = vim.fn.tempname() .. ' with spaces.yaml'
local uri = vim.uri_from_fname(path)

local result, err = handler(nil, { path = uri })
assert(result == vim.NIL and err == nil, 'missing file must return JSON null')
assert(vim.json.encode({ result = result }) == '{"result":null}')

local file = assert(io.open(path, 'wb'))
file:write('name: Test\n')
file:close()
result, err = handler(nil, { path = uri })
assert(result == 'name: Test\n' and err == nil)

file = assert(io.open(path, 'wb'))
file:close()
result, err = handler(nil, { path = uri })
assert(result == '' and err == nil, 'empty file is a valid string response')
vim.fn.delete(path)

for _, params in ipairs({ false, {}, { path = 42 }, { path = 'https://example.com/action.yml' } }) do
  result, err = handler(nil, params)
  assert(result == nil and err.code == vim.lsp.protocol.ErrorCodes.InvalidParams)
end
result, err = handler(nil, nil)
assert(result == nil and err.code == vim.lsp.protocol.ErrorCodes.InvalidParams)
print('Read-file handler tests passed')
