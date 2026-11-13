local M = {}

function M.attach(buf)
  for _, key in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>" }) do
    vim.keymap.set({ "n", "i" }, key, function()
      local mouse = vim.fn.getmousepos()
      if mouse.winid == vim.api.nvim_get_current_win() then
        local cells = require("jupynvim.notebook.cellmode")
        if not cells.is_command(buf) then
          -- An off-screen edit cursor is clamped back into its cell by jupynvim.
          -- Leave cell editing before letting Neovim scroll the viewport.
          vim.cmd.stopinsert()
          cells.enter_command(buf)
        end
      end
      vim.schedule(function()
        vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
      end)
    end, { buffer = buf, silent = true, desc = "Scroll notebook freely" })
  end
end

return M
