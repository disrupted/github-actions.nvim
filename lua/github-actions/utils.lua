local M = {}

---@param msg string
---@param level integer?
M.notify = function(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'github-actions.nvim' })
end

---@param msg string
M.error = function(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

return M
