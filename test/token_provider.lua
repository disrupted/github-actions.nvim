-- Run with: nvim --headless -u NONE -l test/token_provider.lua
vim.opt.rtp:prepend(vim.uv.cwd())
local system = require('github-actions.system')
local provider = require('github-actions.lsp.token_provider')
local completion
system.run = function(cmd, opts, callback)
  assert(vim.deep_equal(cmd, { 'gh', 'auth', 'token' }))
  assert(opts.text == true)
  completion = callback
end
local token
provider.gh(function(value)
  token = value
end)
assert(token == nil)
completion({ code = 0, stdout = 'github_pat_example\n' })
assert(provider.validate(token) == 'github_pat_example')
assert(not pcall(provider.validate, '  '))

local message
require('github-actions.utils').error = function(value)
  message = value
end
token = nil
provider.gh(function(value)
  token = value
end)
completion({ code = 1, stderr = 'not authenticated' })
assert(token == nil and message:find('not authenticated', 1, true))
assert(provider.system == nil)
print('Token provider tests passed')
