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
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_image_provider = "none"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<CR>", desc = "Initialize notebook kernel" },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", desc = "Run notebook cell" },
      { "<leader>mo", "<cmd>MoltenShowOutput<CR>", desc = "Show notebook output" },
      { "<leader>mh", "<cmd>MoltenHideOutput<CR>", desc = "Hide notebook output" },
      { "<leader>md", "<cmd>MoltenDelete<CR>", desc = "Delete notebook output" },
    },
  },
  {
    "GCBallesteros/NotebookNavigator.nvim",
    ft = { "python", "markdown", "quarto" },
    dependencies = { "benlubas/molten-nvim" },
    opts = { repl_provider = "molten", syntax_highlight = true },
    keys = {
      { "<S-CR>", function() require("notebook-navigator").run_and_move() end, desc = "Run cell and move" },
      { "<S-CR>", function()
        require("notebook-navigator").run_and_move()
      end, mode = "i", desc = "Run cell and move" },
      { "<leader>x", function() require("notebook-navigator").run_and_move() end, desc = "Run cell and move" },
      { "<leader>X", function() require("notebook-navigator").run_cell() end, desc = "Run cell" },
      { "]h", function() require("notebook-navigator").move_cell("d") end, desc = "Next cell" },
      { "[h", function() require("notebook-navigator").move_cell("u") end, desc = "Previous cell" },
    },
  },
}
