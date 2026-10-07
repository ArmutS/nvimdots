return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { prefix = "●", source = "if_many" },
        update_in_insert = false,
      },
      servers = {
        jedi_language_server = {},
        rust_analyzer = {},
        clangd = { mason = false }, -- use the system clangd
        ts_ls = {},
        html = {},
        ruff = { enabled = false }, -- Ruff runs through nvim-lint and Conform
        lua_ls = { enabled = false },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = { "ruff", "prettier", "clang-format", "cpptools", "debugpy" }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = { "python", "rust", "cpp", "javascript", "html", "csv", "lua", "vim", "query" }
    end,
  },
}
