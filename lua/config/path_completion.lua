local M = {}

function M.register()
  local source = require("cmp_path").new()
  local dirname = source._dirname

  -- cmp-path requires ./ for relative paths. Also accept quoted Python-style
  -- paths such as "temp/", and suggest the cwd immediately after a quote.
  source._dirname = function(self, params, option)
    local before = params.context.cursor_before_line
    local quoted = before:match("[\"']([^\"']*)$")
    if quoted and not quoted:match("^[~/.$]") and not quoted:match("^%a[%w+.-]*:") then
      local context = vim.tbl_extend("force", params.context, {
        cursor_before_line = before:sub(1, #before - #quoted) .. "./" .. quoted,
      })
      params = vim.tbl_extend("force", params, { context = context })
    end
    return dirname(self, params, option)
  end

  require("cmp").register_source("cwd_path", source)
end

return M
