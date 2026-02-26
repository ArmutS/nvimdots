return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"rust_analyzer",
					"ts_ls",
					"cssls",
					"clangd",
					"fish_lsp",
					"html",
					"jsonls",
					"ltex",
					"sqlls",
					"bashls",
					"svelte",
				},
				automatic_installation = true,
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,
					["ltex"] = function()
						require("lspconfig").ltex.setup({
							capabilities = capabilities,
							cmd_env = {
								JDK_JAVA_OPTIONS = "-Djdk.xml.totalEntitySizeLimit=2000000",
							},
							settings = {
								ltex = {
									language = "tr",
									additionalRules = {
										enablePickyRules = true,
										motherTongue = "tr",
									},
									enabled = {
										"bibtex",
										"gitcommit",
										"markdown",
										"org",
										"tex",
										"restructuredtext",
										"rs",
										"python",
									},
								},
							},
						})
					end,
				},
			})

			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					source = "if_many",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" },
				}),
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
			})
		end,
	},

	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"prettier",
					"sqlfmt",
					"shfmt",
					"pylint",
					"stylelint",
					"ast-grep",
					"cpplint",
					"htmlhint",
					"jsonlint",
					"markdownlint",
					"sqlfluff",
					"shellcheck",
				},
				automatic_installation = true,
				handlers = {},
			})

			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {},
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			require("dapui").setup()

			local dap, dapui = require("dap"), require("dapui")

			local dap = require("dap")
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = "~/.local/share/nvim/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
			}

			dap.adapters.bashdb = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
				name = "bashdb",
			}

			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = true,
				},
				{
					name = "Attach to gdbserver :1234",
					type = "cppdbg",
					request = "launch",
					MIMode = "gdb",
					miDebuggerServerAddress = "localhost:1234",
					miDebuggerPath = "/usr/bin/gdb",
					cwd = "${workspaceFolder}",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
				},
			}

			dap.configurations.rust = {
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = true,
				},
				{
					name = "Attach to gdbserver :1234",
					type = "cppdbg",
					request = "launch",
					MIMode = "gdb",
					miDebuggerServerAddress = "localhost:1234",
					miDebuggerPath = "/usr/bin/gdb",
					cwd = "${workspaceFolder}",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
				},
			}

			dap.configurations.sh = {
				{
					type = "bashdb",
					request = "launch",
					name = "Launch file",
					showDebugOutput = true,
					pathBashdb = vim.fn.stdpath("data")
						.. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
					pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
					trace = true,
					file = "${file}",
					program = "${file}",
					cwd = "${workspaceFolder}",
					pathCat = "cat",
					pathBash = "/bin/bash",
					pathMkfifo = "mkfifo",
					pathPkill = "pkill",
					args = {},
					argsString = "",
					env = {},
					terminalKind = "integrated",
				},
			}

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		config = function()
			require("dap-python").setup("python3")
		end,
	},
}
