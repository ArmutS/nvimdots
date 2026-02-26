vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])


vim.keymap.set("n", "<leader>ww", ":w <CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>wq", ":wq <CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>qq", ":q! <CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>qa", ":qa <CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tt", ":terminal <CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>nn", ":bprevious<CR>", {noremap = true, silent = true})
vim.keymap.set("n", "<leader>bb", ":bnext<CR>", {noremap = true, silent = true})
vim.keymap.set("n", "<leader>sw", ":vsplit<CR>", {noremap = true, silent = true})


vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fg", ":FzfLua live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", ":FzfLua buffers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>uu", require("undotree").toggle, { noremap = true, silent = true })

vim.keymap.set("n", "gh", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

vim.keymap.set("n", "<leader>dc", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<Leader>dt", function()
	require("dap").toggle_breakpoint()
end)

vim.keymap.set("n", "<leader>ee", ":Oil<CR>", { desc = "Open parent directory" })
