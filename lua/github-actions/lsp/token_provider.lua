local utils = require('github-actions.utils')

local M = {}

---@param token string
---@return string token
M.validate = function(token)
  vim.validate('token', token, 'string')
  token = vim.trim(token)
  if not vim.startswith(token, 'ghp_') or #token ~= 40 then
    utils.error('GitHub token provider failed to return valid token string')
  end
  return token
end

---@alias github_actions.lsp.TokenProvider fun(callback: fun(token: string))

--- GH CLI, default token provider
---@type github_actions.lsp.TokenProvider
M.gh = function(callback)
  if not vim.fn.executable('gh') == 1 then
    error('Please install the gh CLI or configure a custom token provider.') -- TODO: vim.health
  end
  vim.system({ 'gh', 'auth', 'token' }, { text = true }, function(out)
    if out.code ~= 0 then
      local msg = 'Error retrieving token from gh CLI'
      if out.stderr then
        msg = msg .. ': ' .. out.stderr
      end
      error(msg)
    end

    callback(assert(out.stdout))
  end)
end

return M
