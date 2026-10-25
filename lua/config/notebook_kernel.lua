local M = {}
local environment = require("config.python_env")
local initialized = {}
local warned = {}
local ready = {}

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
  if environment.python and environment.python ~= "" and vim.fn.executable(environment.python) == 1 then
    return environment.root
  end
end

local function kernel_for_venv()
  local root = active_venv()
  if not root then
    vim.notify(
      "Neovim'i başlattığın terminalin Python'u bulunamadı; ortamı etkinleştirip Neovim'i yeniden aç.",
      vim.log.levels.ERROR
    )
    return nil
  end

  local python = environment.python
  local check = vim.system({ python, "-c", "import ipykernel" }, { text = true }):wait(5000)
  if check.code ~= 0 then
    if not warned[root] then
      vim.notify(
        "Notebook için terminaldeki ortama ipykernel kur: "
          .. vim.fn.shellescape(python)
          .. " -m pip install ipykernel",
        vim.log.levels.WARN
      )
      warned[root] = true
    end
    return nil, "missing-ipykernel"
  end

  local name = "nvim-venv-" .. vim.fn.sha256(root):sub(1, 12)
  local data_home = vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")
  local data_dir = vim.env.JUPYTER_DATA_DIR or (data_home .. "/jupyter")
  local directory = data_dir .. "/kernels/" .. name
  local project = vim.fn.fnamemodify(root, ":h:t")
  local label = vim.fn.fnamemodify(root, ":t")
  local spec = {
    argv = { python, "-m", "ipykernel_launcher", "-f", "{connection_file}" },
    display_name = label .. " (" .. project .. ")",
    language = "python",
  }
  vim.fn.mkdir(directory, "p")
  -- Molten writes a connection file here even when Jupyter uses XDG_RUNTIME_DIR.
  vim.fn.mkdir(data_dir .. "/runtime", "p", 448)
  vim.fn.writefile({ vim.json.encode(spec) }, directory .. "/kernel.json")
  return name
end

function M.init(import_output)
  require("lazy").load({ plugins = { "molten-nvim" } })
  if #vim.fn.MoltenRunningKernels(true) > 0 then
    return true
  end
  local name = kernel_for_venv()
  if not name then
    return false
  end

  local ok, err = pcall(vim.cmd.MoltenInit, name)
  if not ok then
    vim.notify("Notebook kerneli başlatılamadı: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  if require("molten.status").kernels() == "" then
    return false
  end

  if import_output and has_saved_outputs(vim.api.nvim_buf_get_name(0)) then
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(buf)
    local kernel = vim.fn.MoltenRunningKernels(true)[1]
    vim.schedule(function()
      if vim.api.nvim_get_current_buf() == buf then
        vim.cmd("MoltenImportOutput " .. vim.fn.fnameescape(path) .. " " .. kernel)
      end
    end)
  end
  return true
end

local function ensure_kernel()
  if not M.init(false) then
    return false
  end
  local kernels = vim.fn.MoltenRunningKernels(true)
  if
    not vim.wait(15000, function()
      for _, kernel in ipairs(kernels) do
        if not ready[kernel] then
          return false
        end
      end
      return true
    end, 50)
  then
    vim.notify(
      "Notebook kerneli 15 saniyede hazır olmadı. :MoltenInfo ve :Noice history ile ayrıntılara bak.",
      vim.log.levels.ERROR
    )
    return false
  end
  return true
end

local function cells_in_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local cells = {}
  local cell = { marker = 1, first = 1 }
  local function finish(last)
    cell.last = last
    while cell.first <= cell.last and lines[cell.first]:match("^%s*$") do
      cell.first = cell.first + 1
    end
    while cell.last >= cell.first and lines[cell.last]:match("^%s*$") do
      cell.last = cell.last - 1
    end
    cells[#cells + 1] = cell
  end
  for line, text in ipairs(lines) do
    if text:match("^# %%%%") then
      finish(line - 1)
      cell = {
        marker = line,
        first = line + 1,
        skip = text:find("%[markdown%]") or text:find("%[raw%]"),
      }
    end
  end
  finish(#lines)
  return cells, lines
end

local function runnable(cell, lines)
  if cell.skip then
    return false
  end
  for line = cell.first, cell.last do
    if not lines[line]:match("^%s*$") and not lines[line]:match("^%s*#") then
      return true
    end
  end
  return false
end

local function current_cell(cells)
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  for index = #cells, 1, -1 do
    if cursor >= cells[index].marker then
      -- Jupytext's metadata header precedes the first notebook cell.
      if index == 1 and #cells > 1 and vim.api.nvim_buf_get_name(0):match("%.ipynb$") then
        return 2
      end
      return index
    end
  end
  return 1
end

local function evaluate(cells, lines)
  local buf = vim.api.nvim_get_current_buf()
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  if not ensure_kernel() then
    return false
  end
  if vim.api.nvim_get_current_buf() ~= buf or vim.api.nvim_buf_get_changedtick(buf) ~= tick then
    vim.notify("Kernel hazırlanırken tampon değişti; çalıştırma komutunu tekrar kullan.", vim.log.levels.WARN)
    return false
  end
  for _, cell in ipairs(cells) do
    if runnable(cell, lines) then
      vim.fn.MoltenEvaluateRange(cell.first, cell.last, 1, #lines[cell.last] + 1)
    end
  end
  return true
end

function M.run_cell(move)
  local cells, lines = cells_in_buffer()
  local cell = cells[current_cell(cells)]
  local success = not runnable(cell, lines) or evaluate({ cell }, lines)
  if move and success then
    require("notebook-navigator").move_cell("d")
  end
end

function M.run_all()
  local cells, lines = cells_in_buffer()
  return evaluate(cells, lines)
end

function M.run_below()
  local cells, lines = cells_in_buffer()
  return evaluate(vim.list_slice(cells, current_cell(cells)), lines)
end

function M.setup()
  vim.api.nvim_create_user_command("NotebookRunAll", M.run_all, { desc = "Run all notebook code cells" })
  vim.api.nvim_create_user_command("NotebookRunBelow", M.run_below, { desc = "Run current cell and cells below" })
  vim.api.nvim_create_user_command("NotebookRunCell", function()
    M.run_cell(false)
  end, { desc = "Run current notebook cell" })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MoltenKernelReady",
    callback = function(event)
      ready[event.data.kernel_id] = true
    end,
  })

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
        local kernels = vim.fn.MoltenRunningKernels(true)
        if #kernels == 1 then
          -- Escape the path through Neovim's remote-command bootstrap too.
          vim.cmd("MoltenExportOutput! " .. vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) .. " " .. kernels[1])
        end
      end
    end,
  })
end

return M
