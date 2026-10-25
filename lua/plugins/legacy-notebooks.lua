return {
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = { style = "hydrogen", output_extension = "auto" },
  },
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = { "python", "markdown", "quarto" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = #vim.api.nvim_list_uis() > 0 and "image.nvim" or "none"
      vim.g.molten_image_location = "virt"
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_max_lines = 40
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      require("config.notebook_kernel").setup()
    end,
    keys = {
      {
        "<leader>mi",
        function()
          require("config.notebook_kernel").init(false)
        end,
        desc = "Initialize active venv kernel",
      },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", desc = "Run notebook cell" },
      { "<leader>mo", "<cmd>MoltenShowOutput<CR>", desc = "Show notebook output" },
      { "<leader>mh", "<cmd>MoltenHideOutput<CR>", desc = "Hide notebook output" },
      { "<leader>md", "<cmd>MoltenDelete<CR>", desc = "Delete notebook output" },
      { "<leader>ma", "<cmd>NotebookRunAll<CR>", desc = "Run all notebook cells" },
      { "<leader>mb", "<cmd>NotebookRunBelow<CR>", desc = "Run current cell and below" },
    },
  },
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = { enabled = false },
        asciidoc = { enabled = false },
        neorg = { enabled = false },
        rst = { enabled = false },
        typst = { enabled = false },
      },
    },
    config = function(_, opts)
      if #vim.api.nvim_list_uis() > 0 then
        require("image").setup(opts)
      end
    end,
  },
  {
    "GCBallesteros/NotebookNavigator.nvim",
    ft = { "python", "markdown", "quarto" },
    dependencies = { "benlubas/molten-nvim" },
    opts = { repl_provider = "molten", syntax_highlight = true },
    config = function(_, opts)
      local navigator = require("notebook-navigator")
      navigator.setup(opts)
      -- The pinned Molten adapter appends a nil marker when running a whole file.
      -- Keep the public commands working and preserve separate cell outputs.
      navigator.run_all_cells = function()
        return require("config.notebook_kernel").run_all()
      end
      navigator.run_cells_below = function()
        return require("config.notebook_kernel").run_below()
      end
    end,
    keys = {
      {
        "<S-CR>",
        function()
          require("config.notebook_kernel").run_cell(true)
        end,
        desc = "Run cell and move",
      },
      {
        "<S-CR>",
        function()
          require("config.notebook_kernel").run_cell(true)
        end,
        mode = "i",
        desc = "Run cell and move",
      },
      {
        "<leader>x",
        function()
          require("config.notebook_kernel").run_cell(true)
        end,
        desc = "Run cell and move",
      },
      {
        "<leader>X",
        function()
          require("config.notebook_kernel").run_cell(false)
        end,
        desc = "Run cell",
      },
      {
        "]h",
        function()
          require("notebook-navigator").move_cell("d")
        end,
        desc = "Next cell",
      },
      {
        "[h",
        function()
          require("notebook-navigator").move_cell("u")
        end,
        desc = "Previous cell",
      },
    },
  },
}
