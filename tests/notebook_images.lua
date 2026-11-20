-- Run: nvim --clean --headless -i NONE -l tests/notebook_images.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/jupynvim')
local Notebook = require('jupynvim.notebook')
local Render = require('jupynvim.notebook.render')
local adapter = require('config.notebook_images')
adapter.setup()
local normalize = Notebook.normalize_output_data
adapter.setup()
assert(Notebook.normalize_output_data == normalize, 'setup must not wrap normalization twice')
local svg = '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="32"><rect width="64" height="32" fill="red"/></svg>'
local data = {['image/svg+xml'] = {svg}, ['text/plain'] = {'<Figure size 64x32 with 1 Axes>'}}
local buf = vim.api.nvim_get_current_buf()
local nb = Notebook.create(buf, '/tmp/svg-image-test.ipynb', 'test', {cells={
  {id='plot',cell_type='code',source='display(fig)',outputs={{output_type='display_data',data=data}}},
}})
local png = assert(data['image/png'], 'SVG-only saved output must receive a PNG for rendering')
assert(vim.base64.decode(png):sub(1,8) == '\137PNG\r\n\26\n', 'conversion must produce actual PNG bytes')
assert(vim.deep_equal(data['image/svg+xml'], {svg}), 'retain original SVG output')
assert(#Notebook.output_lines(nb.cells[1]) == 0, 'hide the Figure repr when its image can be rendered')
assert(Render._image_outputs(nb,nb.cells[1])[1].mime == 'image/png', 'renderer must discover the converted image')
local live = {['image/svg+xml']=svg, ['text/plain']='<Figure size 64x32 with 1 Axes>'}
nb:apply_cell_event('plot',{kind='display_data',data=live,transient={display_id='plot'}})
assert(live['image/png'], 'live SVG output must also receive a PNG')
local update={['image/svg+xml']=svg:gsub('red','blue')}
nb:apply_cell_event('plot',{kind='update_display_data',display_id='plot',data=update})
assert(update['image/png']~=png, 'updated figures must be converted from their current SVG')
local existing={['image/png']=png,['image/svg+xml']=svg}
Notebook.normalize_output_data(existing)
assert(existing['image/png']==png, 'preserve existing PNG output')
local plain={['text/plain']='ordinary text'}
Notebook.normalize_output_data(plain)
assert(plain['image/png']==nil and plain['text/plain']=='ordinary text')
Notebook.normalize_output_data(nil)
print('PASS: saved and live SVG figures render as PNG; native images and text are preserved')
