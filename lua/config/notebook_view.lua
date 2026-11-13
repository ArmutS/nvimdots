local M = {}

function M.setup(buf)
  local group = vim.api.nvim_create_augroup("NotebookViewport_" .. buf, { clear = true })
  local pending = false

  local function keep_visible()
    if pending or vim.api.nvim_get_current_buf() ~= buf then
      return
    end
    pending = true
    local win = vim.api.nvim_get_current_win()
    -- Let jupynvim finish updating the cell borders and output first.
    vim.schedule(function()
      pending = false
      if vim.api.nvim_get_current_win() ~= win or vim.api.nvim_get_current_buf() ~= buf then
        return
      end
      if not require("jupynvim.notebook").get(buf) or not vim.api.nvim_get_mode().mode:match("^[ni]") then
        return
      end
      local height = vim.api.nvim_win_get_height(win)
      local margin = math.min(3, math.floor(height / 2))
      -- scrolloff stops at EOF and does not reserve space for virtual borders.
      if height - vim.fn.winline() < margin then
        vim.cmd("normal! zz")
      end
    end)
  end

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "InsertEnter", "BufWinEnter" }, {
    group = group,
    buffer = buf,
    callback = keep_visible,
  })
  vim.api.nvim_create_autocmd("WinResized", { group = group, callback = keep_visible })
  keep_visible()
end

return M
