-- Run: nvim --clean --headless -i NONE -l tests/notebook_signature.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local ok, signature = pcall(require, 'config.notebook_signature')
assert(ok, 'notebook signature adapter is missing: ' .. tostring(signature))
local cases = {
  { 'torch.nn.Linear(', 16 },
  { 'fn(1, [2, 3], {"k": (4, 5)}, ', 3 },
  { 'outer(inner(1), ', 6 },
  { 'outer(\n  inner(', 15 },
  { 'fn("(", ', 3 },
  { "fn('(', ", 3 },
  { 'fn("escaped\\\"(", ', 3 },
  { 'fn("""a(b)\nmore""", ', 3 },
  { 'fn( # (ignore)\n  ', 3 },
  { 'fn("inside(', nil },
  { 'fn( # comment', nil },
  { 'fn()', nil },
  { 'def fn(', nil },
  { 'class Thing(', nil },
  { 'items[0', nil },
}
for _, case in ipairs(cases) do
  local actual = signature.call_at(case[1])
  assert(actual == case[2], vim.inspect(case[1]) .. ': expected ' .. tostring(case[2]) .. ', got ' .. tostring(actual))
end
local help = signature.convert({contents={value='```python\nSignature: split(*arrays, test_size=None, random_state=None)\nDocstring:\nSplit arrays into train and test sets.\n```'}})
assert(help.signatures[1].label == 'split(*arrays, test_size=None, random_state=None)')
assert(help.signatures[1].documentation.value == 'Split arrays into train and test sets.')
local init = signature.convert({contents={value='Init signature:\ntorch.nn.Linear(\n    in_features: int,\n    out_features: int,\n    bias: bool = True,\n    device=None,\n    dtype=None,\n)\nDocstring:\nApplies an affine transformation.'}})
assert(init.signatures[1].label == 'torch.nn.Linear( in_features: int, out_features: int, bias: bool = True, device=None, dtype=None, )')
assert(init.signatures[1].documentation.value == 'Applies an affine transformation.')
assert(signature.convert(nil) == nil)
assert(signature.convert({contents={value='No callable information.'}}) == nil)
print('PASS: call detection and multiline signature conversion')

-- The adapter must change only a kernel client's missing signature endpoint.
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/jupynvim')
local buf = vim.api.nvim_get_current_buf()
local forwarded
local client = {
  name = 'jupynvim_kernel',
  server_capabilities = {},
  rpc = {request = function(method, params, callback)
    forwarded = {method=method, params=params}
    callback(nil, {contents={value='Signature: fn(a, b)\nDocstring:\nFunction docs.'}}, 7)
    return 7
  end},
}
local original = client.rpc.request
signature.attach(client, buf)
assert(client.server_capabilities.signatureHelpProvider.triggerCharacters[2] == ',')
local params = {position={line=0,character=3}}
client.rpc.request('textDocument/signatureHelp', params, function(err, help, id)
  assert(err == nil and id == 7)
  assert(help.signatures[1].label == 'fn(a, b)')
end)
assert(forwarded.method == 'textDocument/hover' and forwarded.params == params)
client.rpc.request('textDocument/completion', params, function() end)
assert(forwarded.method == 'textDocument/completion')
local adapted = client.rpc.request
signature.attach(client, buf)
assert(client.rpc.request == adapted, 'reattaching must not wrap RPC twice')
local native = {name='jupynvim_kernel',server_capabilities={signatureHelpProvider={triggerCharacters={'('}}},rpc={request=original}}
signature.attach(native, buf)
assert(native.rpc.request == original, 'preserve native signatureHelp when supplied by a future plugin')
local ordinary = {name='jedi_language_server',server_capabilities={},rpc={request=original}}
signature.attach(ordinary, buf)
assert(ordinary.rpc.request == original and ordinary.server_capabilities.signatureHelpProvider == nil)
local normal = vim.fn.maparg('<C-k>', 'n', false, true)
local insert = vim.fn.maparg('<C-k>', 'i', false, true)
assert(normal.buffer == 1 and insert.buffer == 1)
assert(normal.desc == 'Signature Help' and insert.desc == 'Signature Help')
print('PASS: kernel forwarding, native-provider preservation, and buffer-local keys')

vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/jupynvim')
vim.o.swapfile = false
local notebooks = require('jupynvim.notebook')
local nb = notebooks.create(buf, '/tmp/signature-test.ipynb', 'test', {cells={
  {id='call',cell_type='code',source='fn(argument, other)',outputs={}},
}})
vim.api.nvim_buf_set_lines(buf, 0, -1, false, (nb:to_lines()))
vim.api.nvim_win_set_cursor(0, {1,7})
local pos = signature.call_position(buf)
assert(pos.line == 0 and pos.character == 2, 'resolve the enclosing callable, not the argument')
client.rpc.request('textDocument/signatureHelp', {position={line=0,character=7}}, function() end)
assert(forwarded.params.position.character == 2, 'manual signatureHelp must inspect fn rather than argument')
print('PASS: manual signatureHelp resolves the enclosing callable')

local reply, result
local delayed={name='jupynvim_kernel',server_capabilities={},rpc={request=function(_,_,callback) reply=callback; return 1 end}}
signature.attach(delayed,buf)
delayed.rpc.request('textDocument/signatureHelp',{position={line=0,character=7}},function(_,help) result=help end)
vim.api.nvim_buf_set_lines(buf,0,-1,false,{'different()'})
reply(nil,{contents={value='Signature: fn(a, b)\nDocstring:\nOld docs.'}},1)
assert(result == nil, 'an obsolete reply must not show hints after editing')
vim.api.nvim_win_set_cursor(0,{1,10})
delayed.rpc.request('textDocument/signatureHelp',{position={line=0,character=10}},function(_,help) result=help end)
vim.cmd.enew()
reply(nil,{contents={value='Signature: different()\nDocstring:\nOld docs.'}},1)
assert(result == nil, 'an obsolete reply must not show hints in a different buffer')
print('PASS: stale replies after edits or buffer changes are discarded')

vim.api.nvim_set_current_buf(buf)
local notebook=require('jupynvim')
notebook.config=vim.tbl_deep_extend('force',notebook.config,require('plugins.notebooks')[1].opts())
signature.attach(client,buf)
require('jupynvim.notebook.keymaps').attach(buf,notebook)
vim.wait(400)
assert(vim.fn.maparg('<C-k>','n',false,true).desc == 'Signature Help', 'delayed notebook defaults must not overwrite Ctrl+K')
print('PASS: Ctrl+K survives delayed notebook keymap installation')
