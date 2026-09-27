return {
  -- Keep LazyVim's picker mappings while using the old FzfLua backend.
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local startify = require("alpha.themes.startify")
      startify.section.header.val = {
        [[                                                                       ]],
        [[                                                                     ]],
        [[       ████ ██████           █████      ██                     ]],
        [[      ███████████             █████                             ]],
        [[      █████████ ███████████████████ ███   ███████████   ]],
        [[     █████████  ███    █████████████ █████ ██████████████   ]],
        [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
        [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
        [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      }
      require("alpha").setup(startify.opts)
    end,
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-mini/mini.icons" },
    opts = {},
    keys = {
      { "<leader>ee", "<cmd>Oil<CR>", desc = "Open Oil" },
      { "<leader>pv", "<cmd>Oil<CR>", desc = "Open parent directory" },
    },
  },
  {
    "jiaoshijie/undotree",
    keys = { { "<leader>uu", function() require("undotree").toggle() end, desc = "Toggle undotree" } },
    opts = {
      float_diff = true,
      layout = "left_bottom",
      position = "left",
      window = { width = 0.25, height = 0.25, border = "rounded" },
      ignore_filetype = {},
      parser = "compact",
    },
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({ extensions = { ["ui-select"] = require("telescope.themes").get_dropdown({}) } })
      telescope.load_extension("ui-select")
    end,
  },

  {
    "kkrampis/codex.nvim",
    cmd = { "Codex", "CodexToggle" },
    keys = {
      { "<leader>ac", function() require("codex").toggle() end, mode = { "n", "t" }, desc = "Toggle Codex" },
    },
    opts = {
      keymaps = { quit = "<C-q>" },
      border = "rounded",
      width = 0.8,
      height = 0.8,
      autoinstall = false,
      panel = false,
      use_buffer = false,
    },
  },

  -- Omarchy still chooses the active colorscheme; these are available on demand.
  { "AlexvZyl/nordic.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true, opts = { style = "darker" } },
  { "Mofiqul/dracula.nvim", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
}
