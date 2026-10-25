-- Capture the terminal's interpreter before the provider or plugins change PATH.
local root = vim.env.VIRTUAL_ENV
if not root or root == "" then
  root = vim.env.CONDA_PREFIX
end

local python
if root and root ~= "" then
  root = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
  python = root .. "/bin/python"
else
  python = vim.fn.exepath("python")
  if python == "" then
    python = vim.fn.exepath("python3")
  end
  if python ~= "" then
    root = vim.fn.fnamemodify(python, ":h:h")
  end
end

return { python = python, root = root }
