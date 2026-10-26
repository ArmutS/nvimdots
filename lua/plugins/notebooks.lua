return {
  {
    "sheng-tse/jupynvim",
    tag = "v0.4.6",
    lazy = false, -- Register BufReadCmd before the first notebook is opened.
    build = function(plugin)
      dofile(plugin.dir .. "/lua/jupynvim/install.lua").run(plugin)
    end,
    opts = function()
      local term = vim.env.TERM or ""
      local program = (vim.env.TERM_PROGRAM or ""):lower()
      local graphics = vim.env.KITTY_WINDOW_ID ~= nil
        or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
        or term:find("kitty", 1, true)
        or term:find("ghostty", 1, true)
        or program == "ghostty"
      return {
        log_level = "info",
        image_renderer = graphics and "placeholder" or "chafa",
        max_output_lines = 40,
        auto_venv = true,
        image_cols = 120,
        image_rows = 32,
        -- Jedi sends position requests for Markdown/output lines that the
        -- notebook's code-only LSP view replaces with empty lines.
        -- Use the kernel LSP in notebooks; Jedi still serves ordinary .py files.
        lsp_blocklist = { "jedi_language_server" },
      }
    end,
    config = function(_, opts)
      local notebook = require("jupynvim")
      notebook.setup(opts)

      -- Keep familiar commands and aliases alongside jupynvim's defaults.
      for name, action in pairs({
        NotebookRunCell = function()
          notebook.run_cell(0, { advance = false })
        end,
        NotebookRunAll = function()
          notebook.run_all(0)
        end,
        NotebookRunBelow = function()
          notebook.run_below(0)
        end,
      }) do
        vim.api.nvim_create_user_command(name, action, { desc = name })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("NotebookAliases", { clear = true }),
        callback = function(event)
          if not require("jupynvim.notebook").get(event.buf) then
            return
          end
          local buf = event.buf
          local function map(lhs, action, desc)
            vim.keymap.set("n", lhs, action, { buffer = buf, desc = desc })
          end
          map("<leader>x", function()
            notebook.run_cell(buf, { advance = true })
          end, "Run cell and move")
          map("<leader>X", function()
            notebook.run_cell(buf, { advance = false })
          end, "Run cell")
          map("<leader>mi", function()
            notebook.kernel_picker(buf)
          end, "Select notebook kernel")
          map("<leader>mr", function()
            notebook.run_cell(buf, { advance = false })
          end, "Run notebook cell")
          map("<leader>ma", function()
            notebook.run_all(buf)
          end, "Run all notebook cells")
          map("<leader>mb", function()
            notebook.run_below(buf)
          end, "Run current cell and below")
          map("<leader>mo", function()
            notebook.toggle_output_hidden(buf)
          end, "Toggle notebook output")
          map("<leader>md", function()
            notebook.clear_cell_output(buf)
          end, "Clear notebook cell output")
          map("]h", function()
            notebook.jump_cell(buf, 1)
          end, "Next cell")
          map("[h", function()
            notebook.jump_cell(buf, -1)
          end, "Previous cell")
        end,
      })
    end,
  },
}
