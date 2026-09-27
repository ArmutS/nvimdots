-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next match centered" })
map("n", "N", "Nzzzv", { desc = "Previous match centered" })

map("x", "<leader>p", '"_dP', { desc = "Paste without replacing clipboard" })
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
map("i", "<C-c>", "<Esc>", { desc = "Leave insert mode" })
map("n", "Q", "<Nop>", { desc = "Disable Ex mode" })

map("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
map("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location item" })
map("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location item" })

map("n", "<leader>ww", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>wq", "<cmd>wq<CR>", { desc = "Write and quit" })
map("n", "<leader>qa", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>nn", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fG", "<cmd>FzfLua git_files<CR>", { desc = "Find Git files" })

map("n", "gh", vim.lsp.buf.hover, { desc = "LSP hover" })
map("n", "<leader>gr", vim.lsp.buf.references, { desc = "LSP references" })
