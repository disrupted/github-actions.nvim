local M = {}

---@param opts? github_actions.Opts
M.setup = function(opts)
  require('github-actions.treesitter')

  local Config = require('github-actions.config')

  require('coop').spawn(function()
    Config.setup(opts)

    vim.lsp.config('gh_actions_ls', Config.config.lsp)
    vim.lsp.enable('gh_actions_ls')

    -- since we're lazy-loading we have to start LSP client for current buffer
    if vim.bo.filetype == 'yaml.github' then
      vim.lsp.start(vim.lsp.config.gh_actions_ls)
    end
  end)
end

return M
