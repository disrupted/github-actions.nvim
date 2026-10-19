-- Run with: nvim --headless -u NONE -l test/lsp_setup.lua
vim.opt.rtp:prepend(vim.uv.cwd())

local system = require('github-actions.system')
local completed = false
system.run({ 'sh', '-c', 'sleep 0.05; printf done' }, { text = true }, function(out)
  assert(not vim.in_fast_event())
  assert(out.code == 0 and out.stdout == 'done')
  completed = true
end)
assert(not completed, 'system.run must return before completion')
assert(vim.wait(2000, function()
  return completed
end))

local lsp = require('github-actions.lsp')
local original_run = system.run
local starts = {}
lsp.config = function(config)
  starts[#starts + 1] = config
end
local pending
system.run = function(cmd, opts, callback)
  assert(cmd[1] == 'gh' and cmd[2] == 'repo')
  assert(opts.cwd == vim.fs.root(0, '.git'))
  pending = callback
end
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

local token_callback
local config = {
  token_provider = function(callback)
    token_callback = callback
  end,
  lsp = { init_options = {} },
}
lsp.setup(config)
assert(#starts == 0 and pending == nil)
token_callback('github_pat_example\n')
assert(vim.wait(1000, function()
  return pending ~= nil
end))
assert(#starts == 0, 'must wait for repository discovery')
finish()
assert(#starts == 1)
assert(starts[1].init_options.sessionToken == 'github_pat_example')
assert(starts[1].init_options.repos[1].owner == 'owner')
assert(config.lsp.init_options.repos == nil, 'must not mutate shared options')

pending = nil
lsp.setup({ token_provider = false, lsp = { init_options = {} } })
assert(pending and #starts == 1, 'discover repository even without a token provider')
finish()
assert(#starts == 2)

pending = nil
lsp.setup({ token_provider = false, lsp = { init_options = { repos = {} } } })
assert(pending == nil and #starts == 3, 'respect explicit repository contexts')

local errors = {}
require('github-actions.utils').error = function(message)
  errors[#errors + 1] = message
end
lsp.setup({ token_provider = false, lsp = {} })
pending({ code = 1, stderr = 'discovery failed' })
assert(#starts == 3 and #errors == 1, 'do not initialize without repository context')
pending({ code = 0, stdout = 'invalid json' })
assert(#starts == 3 and #errors == 2)

system.run = original_run
print('LSP setup tests passed')
