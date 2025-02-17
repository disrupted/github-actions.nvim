local utils = require('github-actions.utils')

local M = {}

---@param token string
---@return string token
local function validate_token(token)
  vim.validate('token', token, 'string')
  token = vim.trim(token)
  if not vim.startswith(token, 'ghp_') or #token ~= 40 then
    utils.error('GitHub token provider failed to return valid token string')
  end
  return token
end

---@param token string
---@return nil
local function token_callback(token)
  M.config.lsp.init_options.sessionToken = validate_token(token)
  require('github-actions.lsp').setup(M.config)
end

---@class github_actions.Config
---@field token_provider fun(callback: fun(token: string))
---@field lsp? github_actions.LspConfig

---@class github_actions.LspConfig: vim.lsp.Config
---@field init_options github_actions.LspConfig.InitOptions

---@class github_actions.LspConfig.InitOptions
---@field sessionToken? string

---@type github_actions.Config
local defaults = {
  token_provider = function(callback)
    if not vim.fn.executable('gh') == 1 then
      error('Please install the gh CLI or configure a custom token provider.') -- TODO: vim.health
    end
    vim.system({ 'gh', 'auth', 'token' }, { text = true }, function(out)
      if out.code ~= 0 then
        local msg = 'Error retrieving token from gh CLI'
        if out.stderr then
          msg = msg .. ': ' .. out.stderr
        end
        error(msg)
      end

      callback(assert(out.stdout))
    end)
  end,
  lsp = {
    cmd = { 'gh-actions-language-server', '--stdio' },
    filetypes = { 'yaml.github' },
    root_markers = { '.github' },
    capabilities = {
      workspace = {
        didChangeWorkspaceFolders = {
          dynamicRegistration = true,
        },
      },
    },
    init_options = {},
    handlers = {
      ['textDocument/publishDiagnostics'] = function(err, result, ctx)
        result.diagnostics = vim.tbl_filter(function(diagnostic)
          -- silence annoying context warnings https://github.com/github/vscode-github-actions/issues/222
          if
            diagnostic.severity == vim.diagnostic.severity.WARN
            and diagnostic.message:match('Context access might be invalid:')
          then
            return false
          end

          return true
        end, result.diagnostics)

        vim.lsp.handlers[ctx.method](err, result, ctx)
      end,
    },
  },
}

---@type github_actions.Config
---@diagnostic disable-next-line: missing-fields
M.config = {}

---@class github_actions.Opts: github_actions.Config|{}

---@param opts? github_actions.Opts
function M.setup(opts)
  M.config = vim.tbl_deep_extend('keep', defaults, opts or {})

  if M.config.token_provider then
    utils.notify('Retrieving GitHub token...', vim.log.levels.DEBUG)
    M.config.token_provider(token_callback)
  end
end

return M
