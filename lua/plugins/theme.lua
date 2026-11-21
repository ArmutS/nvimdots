local theme = require("config.omarchy_theme_sync")
local specs = theme.read(theme.path())
return specs or {
  { "LazyVim/LazyVim", opts = { colorscheme = theme.apply_default } },
}
