local M = {}

M.setup = function(opts)
  require('github-actions.treesitter')
  require('github-actions.lsp.config')
end

return M
