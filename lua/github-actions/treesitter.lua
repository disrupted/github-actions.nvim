-- for development
local ft = 'gh_vars' -- GitHub actions variables
vim.filetype.add({
  extension = {
    [ft] = ft,
  },
})

local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
local lang_name = 'githubactions'
parser_config[lang_name] = {
  maintainers = { 'disrupted' },
  filetype = ft,
  install_info = {
    url = 'https://github.com/disrupted/tree-sitter-github-actions',
    files = { 'src/parser.c' },
    branch = 'main',
  },
}
require('nvim-treesitter.install').ensure_installed_sync(lang_name)

-- TODO
-- lang_name = 'githubactionscondition'
-- parser_config[lang_name] = {
--   maintainers = { 'disrupted' },
--   install_info = {
--     url = '~/dev/tree-sitter-github-actions-condition',
--     files = { 'src/parser.c' },
--     branch = 'main',
--   },
-- }
-- require('nvim-treesitter.install').ensure_installed_sync(lang_name)

lang_name = 'githubbash'
parser_config[lang_name] = {
  maintainers = { 'disrupted' },
  filetype = lang_name,
  install_info = {
    url = 'https://github.com/disrupted/tree-sitter-github-bash',
    files = { 'src/parser.c', 'src/scanner.c' },
    branch = 'main',
  },
}
require('nvim-treesitter.install').ensure_installed_sync(lang_name)
