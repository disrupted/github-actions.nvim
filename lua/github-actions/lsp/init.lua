local M = {}

local server_name = 'gh_actions_ls'

---@param config github_actions.Config
M.setup = function(config)
  vim.lsp.config(server_name, config.lsp)
  vim.lsp.enable(server_name)

  -- since we're lazy-loading we have to start LSP client for current buffer
  vim.schedule(function()
    if vim.bo.filetype == 'yaml.github' then
      vim.lsp.start(vim.lsp.config[server_name])
    end
  end)
end

return M
