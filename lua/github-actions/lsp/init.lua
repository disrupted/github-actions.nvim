local utils = require('github-actions.utils')
local token_provider = require('github-actions.lsp.token_provider')

local M = {}

local server_name = 'gh_actions_ls'

---@param config github_actions.Config
M.setup = function(config)
  if config.token_provider then
    utils.notify('Retrieving GitHub token...', vim.log.levels.DEBUG)
    config.token_provider(function(token)
      config.lsp.init_options.sessionToken = token_provider.validate(token)
      M.config(config.lsp)
    end)
  else
    M.config(config.lsp)
  end
end

---@param config github_actions.lsp.Config
M.config = function(config)
  vim.lsp.config(server_name, config)
  vim.lsp.enable(server_name)

  -- since we're lazy-loading we have to start LSP client for current buffer
  vim.schedule(function()
    if vim.bo.filetype == 'yaml.github' then
      vim.lsp.start(vim.lsp.config[server_name])
    end
  end)
end

return M
