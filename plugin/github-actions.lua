-- Lazily load the plugin when a GitHub Actions workflow is opened.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('github_actions_nvim', { clear = true }),
  pattern = 'yaml.github',
  callback = function()
    require('github-actions').setup()
  end,
})
