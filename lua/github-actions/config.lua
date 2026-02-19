local M = {}

---@class github_actions.Config
---@field token_provider github_actions.lsp.TokenProvider|false
---@field lsp? github_actions.lsp.Config

---@class github_actions.lsp.Config: vim.lsp.Config
---@field init_options github_actions.lsp.Config.InitOptions

---@class github_actions.lsp.Config.InitOptions
---@field sessionToken? string
---@field repos? github_actions.lsp.Config.InitOptions.RepositoryContext[]

---@class github_actions.lsp.Config.InitOptions.RepositoryContext
---@field owner string
---@field name string
---@field organizationOwned boolean
---@field workspaceUri lsp.URI

---@type github_actions.Config
local defaults = {
  token_provider = require('github-actions.lsp.token_provider').gh,
  lsp = {
    cmd = { 'gh-actions-language-server', '--stdio' },
    filetypes = { 'yaml.github' },
    root_markers = { '.github' },
    workspace_required = true,
    capabilities = {
      workspace = {
        didChangeWorkspaceFolders = {
          dynamicRegistration = true,
        },
      },
    },
    init_options = {},
    handlers = {
      ['actions/readFile'] = function(_, result)
        if type(result.path) ~= 'string' then
          return nil, nil
        end
        local file_path = vim.uri_to_fname(result.path)
        if vim.fn.filereadable(file_path) == 1 then
          local f = assert(io.open(file_path, 'r'))
          local text = f:read('*a')
          f:close()

          return text, nil
        end
        return nil, nil
      end,
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
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})
end

return M
