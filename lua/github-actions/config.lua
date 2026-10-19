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
    cmd = { 'actions-languageserver', '--stdio' },
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
    ---@type table<vim.lsp.protocol.Methods, lsp.Handler>
    handlers = {
      ---@type lsp.Handler
      ['actions/readFile'] = function(_, params)
        if type(params) ~= 'table' or type(params.path) ~= 'string' then
          return nil,
            {
              code = vim.lsp.protocol.ErrorCodes.InvalidParams,
              message = 'actions/readFile requires a string path',
            }
        end

        local ok, file_path = pcall(vim.uri_to_fname, params.path)
        if not ok or not vim.startswith(params.path, 'file://') then
          return nil,
            {
              code = vim.lsp.protocol.ErrorCodes.InvalidParams,
              message = 'actions/readFile requires a file URI',
            }
        end

        if vim.fn.filereadable(file_path) ~= 1 then
          return vim.NIL
        end

        local f = io.open(file_path, 'rb')
        if not f then
          return vim.NIL
        end

        local text = f:read('*a')
        f:close()
        return text or vim.NIL
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
