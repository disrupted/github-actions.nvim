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
      -- repos
      token_provider.system(
        { 'gh', 'repo', 'view', '--json', 'owner,name,isInOrganization' },
        function(stdout)
          local data = vim.json.decode(stdout)
          config.lsp.init_options.repos = {
            {
              owner = data.owner.login --[[@as string]],
              name = data.name --[[@as string]],
              organizationOwned = data.isInOrganization --[[@as boolean]],
              workspaceUri = vim.uri_from_fname(assert(vim.uv.cwd())),
            },
          }
        end
      )
      M.config(config.lsp)
    end)
  else
    M.config(config.lsp)
  end
end

---@param config github_actions.lsp.Config
M.config = function(config)
  -- since we're lazy-loading we have to start LSP client for current buffer
  vim.schedule(function()
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
    if vim.bo.filetype == 'yaml.github' then
      vim.lsp.start(vim.lsp.config[server_name])
    end
  end)
end

return M
