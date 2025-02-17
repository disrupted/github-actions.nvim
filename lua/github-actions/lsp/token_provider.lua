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

---@alias github_actions.lsp.TokenProvider.callback fun(token: string)
---@alias github_actions.lsp.TokenProvider fun(callback: github_actions.lsp.TokenProvider.callback)

--- Execute shell command to retrieve token
---@param cmd string[]
---@param callback github_actions.lsp.TokenProvider.callback
M.system = function(cmd, callback)
  if vim.tbl_isempty(cmd) then
    error('cmd cannot be empty.')
  end
  if vim.fn.executable(cmd[1]) ~= 1 then
    error(string.format('%s is not executable.', cmd[1])) -- TODO: vim.health
  end
  vim.system(cmd, { text = true }, function(out)
    if out.code ~= 0 then
      local msg = 'Error retrieving token'
      if out.stderr then
        msg = msg .. ': ' .. out.stderr
      end
      error(msg)
    end

    callback(assert(out.stdout))
  end)
end

--- GH CLI, default token provider
---@type github_actions.lsp.TokenProvider
M.gh = function(callback)
  M.system({ 'gh', 'auth', 'token' }, callback)
end

return M
