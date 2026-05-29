vim.cmd("colorscheme carbonfox")
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Ana arka plan
vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })

-- Odakta olmayan pencereler (opsiyonel ama tutarlılık için gerekli)
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })

-- Sol taraftaki işaret sütunu (satır numaralarının yanı)
vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })

-- Kayan pencereler (Telescope, lsp hover vb.)
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })

-- Dosya sonundaki tilde (~) işaretlerinin arka planı
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#000000" })
