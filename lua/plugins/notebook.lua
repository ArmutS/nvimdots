return {
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = {
			style = "hydrogen",
			output_extension = "auto",
		},
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
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
			{ "<leader>mr", "<cmd>MoltenReevaluateCell<CR>", desc = "Run current notebook cell" },
			{ "<leader>mo", "<cmd>MoltenShowOutput<CR>", desc = "Show notebook output" },
			{ "<leader>mh", "<cmd>MoltenHideOutput<CR>", desc = "Hide notebook output" },
			{ "<leader>md", "<cmd>MoltenDelete<CR>", desc = "Delete notebook output" },
		},
	},
	{
		"GCBallesteros/NotebookNavigator.nvim",
		dependencies = {
			"benlubas/molten-nvim",
		},
		ft = { "python", "markdown", "quarto" },
		opts = {
			repl_provider = "molten",
			syntax_highlight = true,
		},
		keys = {
			{
				"<S-CR>",
				function()
					require("notebook-navigator").run_and_move()
				end,
				mode = "n",
				desc = "Run notebook cell and move down",
			},
			{
				"<S-CR>",
				"<Esc><cmd>lua require('notebook-navigator').run_and_move()<CR>",
				mode = "i",
				desc = "Run notebook cell and move down",
			},
			{
				"<leader>x",
				function()
					require("notebook-navigator").run_and_move()
				end,
				desc = "Run notebook cell and move down",
			},
			{
				"<leader>X",
				function()
					require("notebook-navigator").run_cell()
				end,
				desc = "Run notebook cell",
			},
			{
				"]h",
				function()
					require("notebook-navigator").move_cell("d")
				end,
				desc = "Next notebook cell",
			},
			{
				"[h",
				function()
					require("notebook-navigator").move_cell("u")
				end,
				desc = "Previous notebook cell",
			},
		},
	},
}
