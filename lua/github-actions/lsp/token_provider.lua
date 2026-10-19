local utils = require('github-actions.utils')

local M = {}

---@param token string
---@return string token
M.validate = function(token)
  vim.validate('token', token, 'string')
  token = vim.trim(token)
  if token == '' then
    error('GitHub token provider returned an empty token')
  end
  return token
end

---@alias github_actions.lsp.TokenProvider.callback fun(token: string)
---@alias github_actions.lsp.TokenProvider fun(callback: github_actions.lsp.TokenProvider.callback)

--- GH CLI, default token provider
---@type github_actions.lsp.TokenProvider
M.gh = function(callback)
  return require('github-actions.system').run(
    { 'gh', 'auth', 'token' },
    { text = true },
    function(out)
      if out.code ~= 0 then
        local msg = 'Error retrieving token'
        if out.stderr then
          msg = msg .. ': ' .. out.stderr
        end
        utils.error(msg)
        return
      end

      callback(assert(out.stdout))
    end
  )
end

return M
