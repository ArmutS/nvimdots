local M = {}

local python = require("config.python_env").python

function M.run()
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or vim.bo.filetype ~= "python" or file == "" then
    vim.notify("Önce kaydedilmiş bir Python dosyası aç.", vim.log.levels.WARN)
    return
  end
  if not python or python == "" or vim.fn.executable(python) ~= 1 then
    vim.notify("Neovim açılırken seçilen Python bulunamadı: " .. (python or ""), vim.log.levels.ERROR)
    return
  end

  local cwd = vim.fn.getcwd()
  local saved, err = pcall(vim.cmd, "write")
  if not saved then
    vim.notify("Python dosyası kaydedilemedi: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local height = math.max(1, math.floor((vim.o.lines - vim.o.cmdheight) / 2))
  vim.cmd("botright " .. height .. "new")
  local job = vim.fn.jobstart({ python, "-u", file }, { term = true, cwd = cwd })
  if job <= 0 then
    vim.notify("Python başlatılamadı: " .. python, vim.log.levels.ERROR)
    return
  end
  vim.cmd.startinsert()
end

return M
