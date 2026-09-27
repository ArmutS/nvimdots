return {
  -- Use LazyVim's integrations so completion and snippets share its LSP setup.
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
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
