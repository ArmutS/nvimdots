local M = {}
local installed = false

function M.setup()
  if installed then return end
  installed = true
  local notebook = require("jupynvim.notebook")
  local normalize = notebook.normalize_output_data

  -- Jupynvim v0.4.6 renders raster outputs, while d2l emits SVG figures.
  -- Add a display-only PNG when outputs enter the model, including live updates.
  notebook.normalize_output_data = function(data)
    normalize(data)
    if type(data) ~= "table" then return end
    for _, mime in ipairs({ "image/png", "image/gif", "image/jpeg" }) do
      if type(data[mime]) == "string" and data[mime] ~= "" then return end
    end
    local svg = data["image/svg+xml"]
    if type(svg) == "table" then svg = table.concat(svg, "") end
    if type(svg) ~= "string" or svg == "" then return end
    if vim.fn.executable("magick") ~= 1 then
      vim.notify_once("Notebook SVG plots need ImageMagick (magick).", vim.log.levels.WARN)
      return
    end

    local ok, result = pcall(function()
      return vim.system({ "magick", "-background", "none", "svg:-", "png:-" }, { stdin = svg }):wait(5000)
    end)
    if ok and result.code == 0 and result.stdout and result.stdout:sub(1, 8) == "\137PNG\r\n\26\n" then
      data["image/png"] = vim.base64.encode(result.stdout)
    else
      vim.notify_once("Could not render notebook SVG plot as PNG.", vim.log.levels.WARN)
    end
  end
end

return M
