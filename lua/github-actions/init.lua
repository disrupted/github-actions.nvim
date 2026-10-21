local M = {}

---@type github_actions.Opts?
local user_opts
local started = false

--- Configure the plugin. Options are stored until a GitHub Actions buffer is opened
---@param opts? github_actions.Opts
function M.setup(opts)
  user_opts = opts or user_opts

  if vim.bo.filetype ~= 'yaml.github' or started then
    return
  end
  started = true

  local Config = require('github-actions.config')
  Config.setup(user_opts)
  require('github-actions.lsp').setup(Config.config)
end

return M
