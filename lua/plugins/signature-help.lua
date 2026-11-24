local max_width, max_height = 80, 10
local side_padding = 1

local function signature_would_clip(message)
  local width = math.min(max_width, math.max(1, message:width()))
  local height = 0
  for _, line in ipairs(vim.split(message:content(), "\n", { plain = true })) do
    height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / width))
  end

  -- The popup is anchored above the cursor. Include its border and padding.
  local rows_above = vim.fn.winline() - 1
  local columns_right = vim.api.nvim_win_get_width(0) - vim.fn.wincol() + 1
  return math.min(height, max_height) + 2 > rows_above
    or width + 2 * (side_padding + 1) > columns_right
end

return {
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = { event = "lsp", kind = "signature", cond = signature_would_clip },
          opts = { skip = true },
        },
      },
      views = {
        parameter_hints = {
          view = "hover",
          relative = "cursor",
          anchor = "SW",
          position = { row = -1, col = 0 },
          size = { max_width = max_width, max_height = max_height },
          border = { style = "rounded", padding = { 0, side_padding } },
        },
      },
      lsp = {
        signature = {
          enabled = true,
          view = "parameter_hints",
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50,
          },
        },
      },
    },
  },
}
