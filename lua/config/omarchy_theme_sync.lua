-- Follow Omarchy's stable theme path across atomic directory replacements.
local M = { state = { applied = 0 } }
local poll, pending = nil, false
local theme_available
local uv = vim.uv or vim.loop

function M.path()
  return (vim.env.XDG_STATE_HOME or vim.env.HOME .. "/.local/state") .. "/omarchy/current/theme/neovim.lua"
end

local function apply_transparency()
  local transparency = vim.fn.stdpath("config") .. "/plugin/after/transparency.lua"
  if vim.fn.filereadable(transparency) == 1 then vim.cmd.source(transparency) end
end

function M.apply_default()
  if (vim.g.colors_name or ""):match("gruvbox-material") then return end
  if not pcall(vim.cmd.colorscheme, "gruvbox-material") then
    vim.cmd.colorscheme("habamax")
  end
  apply_transparency()
end

function M.read(path)
  local chunk, load_error = loadfile(path)
  if not chunk then return nil, load_error end
  local ok, specs = pcall(chunk)
  if not ok then return nil, specs end
  if type(specs) ~= "table" then return nil, "Omarchy theme must return plugin specs" end
  local colorscheme
  for _, spec in ipairs(specs) do
    if type(spec) ~= "table" then return nil, "Invalid Omarchy plugin spec" end
    if spec[1] == "LazyVim/LazyVim" and type(spec.opts) == "table" then
      colorscheme = spec.opts.colorscheme
    end
  end
  if type(colorscheme) ~= "string" or colorscheme == "" then
    return nil, "Omarchy theme has no colorscheme"
  end
  return specs, colorscheme
end

function M.sync()
  local specs, colorscheme = M.read(M.theme_file)
  if not specs then return false, colorscheme end
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
  apply_transparency()
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
    if vim.fn.filereadable(M.theme_file) == 0 then
      if theme_available or not vim.g.colors_name then
        M.apply_default()
        M.state.colorscheme = vim.g.colors_name
      end
      theme_available = false
      M.state.error = nil
      return
    end
    theme_available = true
    local ok, result, err = pcall(M.sync)
    if not ok or not result then
      local message = tostring(ok and err or result)
      if M.state.error ~= message then
        M.apply_default()
        M.state.colorscheme = vim.g.colors_name
        M.state.error = message
        vim.notify("Omarchy theme: " .. message, vim.log.levels.WARN)
      end
    end
  end, 120)
end

function M.setup(opts)
  opts = opts or {}
  if poll then poll:stop(); if not poll:is_closing() then poll:close() end end
  M.theme_file = opts.theme_file or M.path()
  local group = vim.api.nvim_create_augroup("OmarchyThemeSync", { clear = true })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "LazyReload", callback = refresh })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = function()
    if poll and not poll:is_closing() then poll:stop(); poll:close() end
  end })
  vim.api.nvim_create_user_command("OmarchyThemeSync", refresh, { force = true, desc = "Reload current Omarchy colors" })
  poll = uv.new_fs_poll()
  -- Poll the symlink target; fs_event/LazyReload can miss atomic theme directory swaps.
  poll:start(M.theme_file, 1000, function() vim.schedule(refresh) end)
  refresh()
end
return M
