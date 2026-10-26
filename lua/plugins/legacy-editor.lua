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
      -- A CLI exit (or a Neovim restart) should continue this directory's last chat.
      cmd = { "codex", "resume", "--last" },
      keymaps = { quit = "<C-q>" },
      border = "rounded",
      width = 0.8,
      height = 0.8,
      autoinstall = false,
      panel = false,
      use_buffer = false,
    },
    config = function(_, opts)
      local codex = require("codex")
      local state = require("codex.state")
      codex.setup(opts)

      local open = codex.open
      codex.open = function()
        -- codex.nvim keeps the terminal buffer after the CLI exits. A new job
        -- needs a fresh buffer; a running job stays intact when its window hides.
        if not state.job and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
          codex.close()
          vim.api.nvim_buf_delete(state.buf, { force = true })
          state.buf = nil
        end
        open()
        if state.buf and vim.api.nvim_buf_is_valid(state.buf) and vim.bo[state.buf].buftype == "terminal" then
          if opts.keymaps.quit then
            vim.keymap.set({ "n", "t" }, opts.keymaps.quit, codex.close, {
              buffer = state.buf,
              silent = true,
              desc = "Hide Codex",
            })
          end
          vim.cmd.startinsert()
        end
      end
    end,
  },

  -- Omarchy still chooses the active colorscheme; these are available on demand.
  { "AlexvZyl/nordic.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true, opts = { style = "darker" } },
  { "Mofiqul/dracula.nvim", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
}
