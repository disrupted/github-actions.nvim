local utils = require('github-actions.utils')
local system = require('coop.vim').system

local M = {}

---@class github_actions.Config
---@field token_provider? async fun(): string?
---@field lsp? github_actions.LspConfig
---@class github_actions.LspConfig: vim.lsp.Config
---@field init_options github_actions.LspConfig.InitOptions
---@class github_actions.LspConfig.InitOptions
---@field sessionToken? string

---@type github_actions.Config
local defaults = {
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

---@param token string
local function validate_token(token)
  if not vim.startswith(token, 'ghp_') or #token ~= 40 then
    utils.error(string.format('GitHub token provider failed to return valid token string'))
    return
  end
end

---@type github_actions.Config
---@diagnostic disable-next-line: missing-fields
M.config = {}

---@class github_actions.Opts: github_actions.Config|{}

---@async
---@param opts? github_actions.Opts
function M.setup(opts)
  M.config = vim.tbl_deep_extend('keep', defaults, opts or {})

  if M.config.token_provider then
    local token = assert(M.config.token_provider())
    validate_token(token)
    M.config.lsp.init_options.sessionToken = token
  end
end

return M
