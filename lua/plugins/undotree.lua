return {
  "jiaoshijie/undotree",
  config = function ()
    require('undotree').setup({
    float_diff = true, -- set this `true` will disable layout option
    --- @type "left_bottom" | "left_left_bottom"
    layout = "left_bottom", -- {left}_{bottom} {left}_{left_bottom}
    --- @type "left" | "right"
    position = "left",
    window = {
        width = 0.25, -- the `undotree` window width percentage related to the editor
        height = 0.25, -- the `preview`(not floating) window height percentage related to the editor
        border = "rounded", -- float window
    },

    ignore_filetype = {},
    --- @type "compact" | "legacy"
    parser = "compact",
})
  end
}
