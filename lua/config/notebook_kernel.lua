local M = {}
local initialized = {}
local warned = {}

local function has_saved_outputs(path)
  local file = io.open(path, "r")
  if not file then
    return false
  end
  local contents = file:read("*a")
  file:close()
  local ok, notebook = pcall(vim.json.decode, contents)
  if not ok or type(notebook) ~= "table" then
    return false
  end
  for _, cell in ipairs(notebook.cells or {}) do
    if cell.cell_type == "code" and type(cell.outputs) == "table" and #cell.outputs > 0 then
      return true
    end
  end
  return false
end

local function active_venv()
  local root = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
  if not root or root == "" then
    return nil
  end
  root = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
  local python = root .. "/bin/python"
  return vim.fn.executable(python) == 1 and root or nil
end

local function kernel_for_venv()
  local root = active_venv()
  if not root then
    return nil, "no-venv"
  end

  local python = root .. "/bin/python"
  local check = vim.system({ python, "-c", "import ipykernel" }, { text = true }):wait(5000)
  if check.code ~= 0 then
    if not warned[root] then
      vim.notify("Notebook için bu venv'e ipykernel kur: " .. python .. " -m pip install ipykernel", vim.log.levels.WARN)
      warned[root] = true
    end
    return nil, "missing-ipykernel"
  end

  local name = "nvim-venv-" .. vim.fn.sha256(root):sub(1, 12)
  local data_dir = vim.env.JUPYTER_DATA_DIR or vim.fn.expand("~/.local/share/jupyter")
  local directory = data_dir .. "/kernels/" .. name
  local project = vim.fn.fnamemodify(root, ":h:t")
  local label = vim.fn.fnamemodify(root, ":t")
  local spec = {
    argv = { python, "-m", "ipykernel_launcher", "-f", "{connection_file}" },
    display_name = label .. " (" .. project .. ")",
    language = "python",
  }
  vim.fn.mkdir(directory, "p")
  vim.fn.writefile({ vim.json.encode(spec) }, directory .. "/kernel.json")
  return name
end

function M.init(import_output)
  local name, reason = kernel_for_venv()
  if not name then
    if reason == "no-venv" and not import_output then
      vim.cmd.MoltenInit()
    end
    return false
  end

  require("lazy").load({ plugins = { "molten-nvim" } })
  local ok, err = pcall(vim.cmd.MoltenInit, name)
  if not ok then
    vim.notify("Notebook kerneli başlatılamadı: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  if import_output and has_saved_outputs(vim.api.nvim_buf_get_name(0)) then
    vim.schedule(function()
      pcall(vim.cmd.MoltenImportOutput)
    end)
  end
  return true
end

function M.run_cell(move)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local marker = nil
  for line = cursor, 1, -1 do
    if lines[line]:sub(1, 4) == "# %%" then
      marker = line
      break
    end
  end
  if not marker and vim.api.nvim_buf_get_name(0):match("%.ipynb$") then
    for line, text in ipairs(lines) do
      if text:sub(1, 4) == "# %%" then
        marker = line
        break
      end
    end
  end
  if marker and lines[marker]:find("%[markdown%]") then
    if move then
      require("notebook-navigator").move_cell("d")
    end
    return
  end

  local first = marker and marker + 1 or 1
  local last = #lines
  for line = first, #lines do
    if lines[line]:sub(1, 4) == "# %%" then
      last = line - 1
      break
    end
  end
  while first <= last and lines[first]:match("^%s*$") do
    first = first + 1
  end
  while last >= first and lines[last]:match("^%s*$") do
    last = last - 1
  end
  if first > last then
    return
  end

  if require("molten.status").kernels() == "" then
    if M.init(false) then
      vim.notify("Kernel başlatılıyor; hazır olduğunda hücreyi tekrar çalıştır.", vim.log.levels.INFO)
    end
    return
  end

  vim.fn.MoltenEvaluateRange(first, last, 1, #lines[last] + 1)
  if move then
    require("notebook-navigator").move_cell("d")
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.ipynb",
    callback = function(args)
      local buf = args.buf
      if initialized[buf] or not active_venv() then
        return
      end
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf and M.init(true) then
          initialized[buf] = true
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.ipynb",
    callback = function()
      local ok, status = pcall(require, "molten.status")
      if ok and status.initialized() == "Molten" then
        vim.cmd("MoltenExportOutput!")
      end
    end,
  })
end

return M
