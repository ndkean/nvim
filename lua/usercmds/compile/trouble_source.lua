---@class trouble.Source.compile: trouble.Source
local M = {}

---@type trouble.Item[]
M.items = {}

M.config = {
  modes = {
    comp_failure = {
      desc = 'Errors during compile',
      source = 'compile',
      title = '{hl:Title}Compilation Errors{hl}',
      groups = {
        { 'directory' },
        { 'filename', format = '{file_icon} {filename} {count}' },
      },
      sort = { 'severity', 'filename', 'pos' },
      format = '{severity} {item.message} {pos}',
    },
  },
}

---@param cb trouble.Source.Callback
---@param _ctx trouble.Source.ctx)
function M.get(cb, _ctx)
  cb(M.items)
end

return M
