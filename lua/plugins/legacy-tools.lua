return {
  -- The old null-ls config had no sources. Keep it available without competing
  -- with LazyVim's Conform and nvim-lint pipelines.
  {
    "nvimtools/none-ls.nvim",
    cmd = "NullLsInfo",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { sources = {} },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    lazy = true,
    opts = { automatic_installation = false, handlers = {} },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        markdown = { "prettier" },
        sql = { "sqlfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "pylint" },
        css = { "stylelint" },
        cpp = { "cpplint" },
        html = { "htmlhint" },
        json = { "jsonlint" },
        markdown = { "markdownlint" },
        sql = { "sqlfluff" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },
}
