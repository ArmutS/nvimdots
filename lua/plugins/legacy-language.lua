return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { prefix = "●", source = "if_many" },
        update_in_insert = false,
      },
      servers = {
        pyright = {},
        rust_analyzer = {},
        ts_ls = {},
        cssls = {},
        clangd = {},
        fish_lsp = {},
        html = {},
        jsonls = {},
        ltex = {
          cmd_env = { JDK_JAVA_OPTIONS = "-Djdk.xml.totalEntitySizeLimit=2000000" },
          settings = {
            ltex = {
              language = "tr",
              additionalRules = { enablePickyRules = true, motherTongue = "tr" },
              enabled = { "bibtex", "gitcommit", "markdown", "org", "tex", "restructuredtext", "rs", "python" },
            },
          },
        },
        sqlls = {},
        bashls = {},
        svelte = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
        "sqlfmt",
        "pylint",
        "stylelint",
        "ast-grep",
        "cpplint",
        "htmlhint",
        "jsonlint",
        "markdownlint",
        "sqlfluff",
        "shellcheck",
        "cpptools",
        "bash-debug-adapter",
        "debugpy",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = true } },
  },
}
