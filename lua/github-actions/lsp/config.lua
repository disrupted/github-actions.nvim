local configs = require('lspconfig.configs')

if not configs['gh_actions_ls'] then
  configs['gh_actions_ls'] = {
    default_config = {
      cmd = {
        'gh-actions-language-server',
        '--stdio',
      },
      filetypes = { 'yaml.github' },
      single_file_support = true,
      root_dir = function(fname)
        return vim.uv.cwd()
      end,
      handlers = {
        ['textDocument/publishDiagnostics'] = function(err, result, ctx)
          result.diagnostics = vim.tbl_filter(function(diagnostic)
            -- print(vim.inspect(diagnostic))

            -- silence annoying context warnings https://github.com/github/vscode-github-actions/issues/222
            if
              diagnostic.severity == vim.diagnostic.severity.WARN
              and diagnostic.message:match('Context access might be invalid:')
            then
              return false
            end

            return true
          end, result.diagnostics)

          vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx)
        end,
      },
    },
  }
end
