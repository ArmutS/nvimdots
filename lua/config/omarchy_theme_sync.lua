-- Follow Omarchy's stable theme path across atomic directory replacements.
local M = { state = { applied = 0 } }
local poll, pending = nil, false
local uv = vim.uv or vim.loop

function M.sync()
  local chunk, load_error = loadfile(M.theme_file)
  if not chunk then return false, load_error end
  local ok, specs = pcall(chunk)
  if not ok then return false, specs end
  local colorscheme
  for _, spec in ipairs(specs) do
    if spec[1] == "LazyVim/LazyVim" and type(spec.opts) == "table" then
      colorscheme = spec.opts.colorscheme
    end
  end
  if not colorscheme then return false, "Omarchy theme has no colorscheme" end
  local plugins = require("lazy.core.config").plugins
  for _, spec in ipairs(specs) do
    if spec[1] and spec[1] ~= "LazyVim/LazyVim" then
      local name = spec.name or spec[1]:match("/([^/]+)$")
      local plugin = plugins[name]
      if not plugin then return false, "Theme plugin is not installed: " .. tostring(name) end
      require("lazy").load({ plugins = { name } })
      if type(spec.opts) == "table" then
        local main = spec.main or require("lazy.core.loader").get_main(plugin)
        if main then
          local theme = require(main)
          if type(theme.setup) == "function" then theme.setup(vim.deepcopy(spec.opts)) end
        end
      end
    end
  end
  -- Do not clear highlights until the current theme has been read successfully.
  vim.cmd.colorscheme(colorscheme)
  local transparency = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"
  if vim.fn.filereadable(transparency) == 1 then vim.cmd.source(transparency) end
  M.state.applied = M.state.applied + 1
  M.state.colorscheme = colorscheme
  M.state.error = nil
  vim.cmd("redraw")
  return true
end

local function refresh()
  if pending then return end
  pending = true
  vim.defer_fn(function()
    pending = false
    if vim.fn.filereadable(M.theme_file) == 0 then return end
    local ok, result, err = pcall(M.sync)
    if not ok or not result then
      local message = tostring(ok and err or result)
      if M.state.error ~= message then
        M.state.error = message
        vim.notify("Omarchy theme: " .. message, vim.log.levels.WARN)
      end
    end
  end, 120)
end

function M.setup(opts)
  opts = opts or {}
  if poll then poll:stop(); if not poll:is_closing() then poll:close() end end
  M.theme_file = opts.theme_file or ((vim.env.XDG_STATE_HOME or vim.env.HOME .. "/.local/state") .. "/omarchy/current/theme/neovim.lua")
  local group = vim.api.nvim_create_augroup("OmarchyThemeSync", { clear = true })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "LazyReload", callback = refresh })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = function()
    if poll and not poll:is_closing() then poll:stop(); poll:close() end
  end })
  vim.api.nvim_create_user_command("OmarchyThemeSync", refresh, { force = true, desc = "Reload current Omarchy colors" })
  poll = uv.new_fs_poll()
  -- Poll the symlink target; fs_event/LazyReload can miss atomic theme directory swaps.
  poll:start(M.theme_file, 1000, function(err) if not err then vim.schedule(refresh) end end)
  refresh()
end
return M
