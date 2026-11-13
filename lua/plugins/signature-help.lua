return {
  {
    "folke/noice.nvim",
    opts = {
      views = {
        parameter_hints = {
          view = "hover",
          relative = "cursor",
          anchor = "SW",
          position = { row = -1, col = 0 },
          size = { max_width = 80, max_height = 10 },
          border = { style = "rounded", padding = { 0, 1 } },
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
