local M = {}

--- Run a command without blocking, delivering completion on the main loop.
---@param cmd string[]
---@param opts vim.SystemOpts?
---@param callback fun(out: vim.SystemCompleted)
function M.run(cmd, opts, callback)
  return vim.system(cmd, opts or {}, vim.schedule_wrap(callback))
end

return M
