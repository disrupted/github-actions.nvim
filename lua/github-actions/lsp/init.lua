local utils = require('github-actions.utils')
local token_provider = require('github-actions.lsp.token_provider')
local system = require('github-actions.system')

local M = {}

local server_name = 'gh_actions_ls'

---@param config github_actions.Config
M.setup = function(config)
  if not config.lsp then
    return
  end

  local root = vim.fs.root(0, '.git') or vim.uv.cwd()
  local lsp = vim.deepcopy(config.lsp)
  lsp.init_options = lsp.init_options or {}

  local function start()
    M.config(lsp)
  end

  local function discover_repository()
    -- explicit repository contexts take precedence over automatic discovery
    if lsp.init_options.repos then
      start()
      return
    end
    system.run(
      { 'gh', 'repo', 'view', '--json', 'owner,name,isInOrganization' },
      { cwd = root, text = true },
      function(out)
        if out.code ~= 0 then
          utils.error('Unable to discover GitHub repository: ' .. vim.trim(out.stderr or ''))
          return
        end
        local ok, data = pcall(vim.json.decode, out.stdout or '')
        if
          not ok
          or type(data) ~= 'table'
          or type(data.owner) ~= 'table'
          or type(data.owner.login) ~= 'string'
          or type(data.name) ~= 'string'
        then
          utils.error('Invalid repository response from gh repo view')
          return
        end
        lsp.init_options.repos = {
          {
            owner = data.owner.login,
            name = data.name,
            organizationOwned = data.isInOrganization,
            workspaceUri = vim.uri_from_fname(assert(root)),
          },
        }
        start()
      end
    )
  end

  if config.token_provider then
    utils.notify('Retrieving GitHub token...', vim.log.levels.DEBUG)
    config.token_provider(vim.schedule_wrap(function(token)
      local ok, value = pcall(token_provider.validate, token)
      if not ok then
        utils.error('GitHub token provider failed: ' .. tostring(value))
        return
      end
      lsp.init_options.sessionToken = value
      discover_repository()
    end))
  else
    discover_repository()
  end
end

---@param config github_actions.lsp.Config
M.config = function(config)
  vim.schedule(function()
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
  end)
end

return M
