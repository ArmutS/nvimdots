return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = {
        python = { "ruff_format" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        html = { "prettier" },
      }
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = { stdin = false, args = { "--write", "$FILENAME" } }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = { python = { "ruff" } }
    end,
  },
}
