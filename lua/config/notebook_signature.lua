-- jupynvim v0.4.6 exposes kernel inspection as hover, but not signatureHelp.
local M = {}

function M.convert(result)
  local text = result and result.contents and result.contents.value
  if type(text) ~= "string" then return nil end
  text = text:gsub("^```[^\n]*\n", ""):gsub("\n```%s*$", "")
  local label = text:match("Signature:%s*(.-)\nDocstring:")
    or text:match("Init signature:%s*(.-)\nDocstring:")
    or text:match("Init signature:%s*(.-)\n")
    or text:match("Signature:%s*(.-)\n")
    or text:match("^([^\n]+)")
  if not label or not label:find("(", 1, true) then return nil end
  return {
    signatures = { {
      label = vim.trim(label):gsub("%s+", " "),
      documentation = { kind = "plaintext", value = text:match("Docstring:%s*(.*)") or text },
    } },
    activeSignature = 0,
  }
end

-- Find an enclosing call in the source before the insertion cursor.
-- Ignore parentheses in strings/comments and track nested argument containers.
function M.call_at(code)
  local stack, quote, comment = {}, nil, false
  local i = 1
  while i <= #code do
    local c = code:sub(i, i)
    if comment then
      if c == "\n" then comment = false end
    elseif quote then
      if c == "\\" then
        i = i + 1
      elseif code:sub(i, i + #quote - 1) == quote then
        i = i + #quote - 1
        quote = nil
      end
    elseif c == "#" then
      comment = true
    elseif c == "'" or c == '"' then
      quote = code:sub(i, i + 2) == c:rep(3) and c:rep(3) or c
      i = i + #quote - 1
    elseif c == "(" or c == "[" or c == "{" then
      local before = code:sub(1, i - 1):gsub("%s+$", "")
      stack[#stack + 1] = {
        char = c, offset = i,
        call = c == "(" and before:match("[%w_%)%]]$") ~= nil
          and not before:match("def%s+[%w_]+$")
          and not before:match("class%s+[%w_]+$"),
      }
    elseif c == ")" or c == "]" or c == "}" then
      if #stack > 0 then table.remove(stack) end
    end
    i = i + 1
  end
  if quote or comment then return nil end
  for n = #stack, 1, -1 do
    if stack[n].call then return stack[n].offset end
  end
end

function M.call_position(buf)
  local nb = require("jupynvim.notebook").get(buf)
  if not nb then return nil end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local id, range = nb:cell_at_line(cursor[1])
  local cell = id and nb:get_cell(id)
  if not cell or cell.cell_type ~= "code" then return nil end
  local lines = vim.api.nvim_buf_get_lines(buf, range.start, cursor[1], false)
  lines[#lines] = lines[#lines]:sub(1, cursor[2])
  local code = table.concat(lines, "\n")
  local opening = M.call_at(code)
  if not opening then return nil end
  local prefix = code:sub(1, opening - 1)
  local _, rows = prefix:gsub("\n", "")
  return { line = range.start + rows, character = #(prefix:match("[^\n]*$") or "") }
end

function M.auto_help(client, buf)
  if vim.api.nvim_get_current_buf() ~= buf or vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then return end
  local pos = M.call_position(buf)
  if not pos then return end
  local params = { textDocument = { uri = vim.uri_from_bufnr(buf) }, position = pos }
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  client:request("textDocument/signatureHelp", params, function(err, result, ctx)
    if vim.api.nvim_get_current_buf() ~= buf or vim.api.nvim_buf_get_changedtick(buf) ~= tick then return end
    local now = M.call_position(buf)
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" or not now or now.line ~= pos.line or now.character ~= pos.character then return end
    require("noice.lsp.signature").on_signature(err, result, ctx, {
      trigger = true,
      stay = function()
        return vim.api.nvim_get_current_buf() == buf
          and vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
          and M.call_position(buf) ~= nil
      end,
    })
  end, buf)
end

function M.attach(client, buf)
  if not client or client.name ~= "jupynvim_kernel" then return end
  if not client.server_capabilities.signatureHelpProvider then
    local request = client.rpc.request
    client.rpc.request = function(method, params, callback, notify)
      if method ~= "textDocument/signatureHelp" then
        return request(method, params, callback, notify)
      end
      -- Inspect the callable even when Ctrl+K is pressed over an argument.
      local call = vim.api.nvim_get_current_buf() == buf and M.call_position(buf) or nil
      if call then params = vim.tbl_extend("force", params, { position = call }) end
      local tick = vim.api.nvim_buf_get_changedtick(buf)
      local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
      return request("textDocument/hover", params, function(err, result, id)
        -- Noice's own automatic requests also pass through this adapter.
        -- Discard late replies before either signature handler can display them.
        if not vim.api.nvim_buf_is_valid(buf)
          or vim.api.nvim_get_current_buf() ~= buf
          or vim.api.nvim_buf_get_changedtick(buf) ~= tick
          or vim.api.nvim_get_mode().mode:sub(1, 1) ~= mode then
          return callback(nil, nil, id)
        end
        if call then
          local now = M.call_position(buf)
          if not now or now.line ~= call.line or now.character ~= call.character then
            return callback(nil, nil, id)
          end
        end
        callback(err, not err and M.convert(result) or nil, id)
      end, notify)
    end
    client.server_capabilities.signatureHelpProvider = { triggerCharacters = { "(", "," } }
  end
  -- Resolve Noice at invocation time; do not capture the pre-Noice handler.
  vim.keymap.set({ "n", "i" }, "<C-k>", function()
    require("noice.lsp").signature()
  end, { buffer = buf, desc = "Signature Help" })

  -- cmp otherwise flips its menu above the cursor near the window bottom.
  -- Reserve room for the six-row menu while editing notebook cells.
  local pending = 0
  vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI", "TextChangedI" }, {
    group = vim.api.nvim_create_augroup("NotebookCompletionRoom" .. buf, { clear = true }),
    buffer = buf,
    callback = function()
      if vim.fn.winline() > vim.api.nvim_win_get_height(0) - 9 then
        vim.cmd("normal! zz")
      end
      pending = pending + 1
      local current = pending
      vim.defer_fn(function()
        if current == pending and vim.api.nvim_buf_is_valid(buf) then
          M.auto_help(client, buf)
        end
      end, 120)
    end,
  })
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("NotebookSignatureHelp", { clear = true }),
    callback = function(event)
      M.attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
    end,
  })
end

return M
