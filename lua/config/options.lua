-- Options are automatically loaded before lazy.nvim startup.
require("config.python_runner")
local python_provider = vim.fn.stdpath("data") .. "/python-provider"
vim.g.python3_host_prog = python_provider .. "/bin/python"
vim.env.PATH = vim.env.PATH .. ":" .. python_provider .. "/bin"
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- Editing preferences carried over from the previous config.
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
