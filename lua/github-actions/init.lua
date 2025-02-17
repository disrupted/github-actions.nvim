local M = {}

---@param opts? github_actions.Opts
M.setup = function(opts)
  require('github-actions.treesitter')
  require('github-actions.config').setup(opts)
end

return M
