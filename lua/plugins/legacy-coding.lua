return {
  -- Use LazyVim's integrations so completion and snippets share its LSP setup.
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      require("config.path_completion").register()
      for _, source in ipairs(opts.sources) do
        if source.name == "path" then
          source.name = "cwd_path"
          source.keyword_length = 0
          source.option = vim.tbl_deep_extend("force", source.option or {}, {
            get_cwd = function()
              return vim.fn.getcwd()
            end,
            trailing_slash = true,
          })
        end
      end
      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      end, { "i", "s" })
      opts.mapping["<CR>"] = nil
    end,
  },
}
