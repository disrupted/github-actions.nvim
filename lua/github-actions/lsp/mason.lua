local Pkg = require('mason-core.package')
local npm = require('mason-core.managers.npm')

return Pkg.new({
  name = 'gh-actions-language-server',
  desc = [[Github Actions Language Server]],
  homepage = 'https://github.com/lttb/gh-actions-language-server',
  languages = { Pkg.Lang.Yaml },
  categories = { Pkg.Cat.LSP },
  install = npm.packages({
    'gh-actions-language-server',
    bin = { 'gh-actions-language-server' },
  }),
})
