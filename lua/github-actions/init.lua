local M = {}

---@param opts? github_actions.Opts
M.setup = function(opts)
  require('github-actions.treesitter')
  local Config = require('github-actions.config')
  Config.setup(opts)
  require('github-actions.lsp').setup(Config.config)
end

return M
