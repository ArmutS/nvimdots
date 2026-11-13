# Notebook help and scrolling implementation plan

> **For agentic workers:** Use superpowers:executing-plans to apply this supplied configuration in place. Do not create commits or replace the user's existing changes.

**Goal:** Apply the desktop notebook signature help, completion layout, and mouse scrolling behavior to this Neovim configuration.

**Architecture:** Adapt jupynvim's kernel hover responses to signatureHelp only when its kernel client lacks native support. Keep notebook-specific keys and scrolling buffer-local; merge Noice and nvim-cmp options into existing plugin specs.

**Tech Stack:** Neovim 0.12.6, LazyVim, nvim-cmp, Noice, jupynvim v0.4.6.

**Spec:** `/home/pinocchio/Downloads/nvim-notebook-degisiklikleri.txt`

## Global constraints

- Preserve existing keymaps, path completion, notebook viewport adjustment, Jedi exclusion, and unrelated user changes.
- Signature window: above cursor, maximum 80 columns and 10 lines, signature plus documentation.
- Ctrl+K: signature help in normal and insert modes in notebooks; K: existing hover.
- Completion: prefer below cursor, at most 6 rows; notebook editing reserves 9 screen rows using zz.
- Notebook mouse wheel exits cell editing before scrolling.
- Back up changed files before editing. Do not update dependencies or lockfile.
- Context7 is unavailable; verify compatibility using installed plugin source.

## Review focus

- Multiline class signatures must retain every constructor argument.
- Call detection must ignore strings/comments and account for nested containers.
- Async replies must not reopen hints after leaving the call or switching buffers.
- Notebook overrides must leave ordinary Python buffers and native signature providers intact.
- Mouse scrolling must not be undone by automatic viewport adjustment.

### Task 1: Signature adapter and help UI

- [x] Add and run regression tests for conversion and call detection, confirming the adapter is absent initially.
- [x] Add `lua/config/notebook_signature.lua` and `lua/plugins/signature-help.lua` from the supplied specification, adapting only where local APIs require it.
- [x] Add signature setup before jupynvim setup; test kernel request forwarding, native provider preservation, normal/insert keys, and cursor-entry help.

### Task 2: Scrolling and completion

- [x] Add `lua/config/notebook_scroll.lua` and attach only in the existing notebook FileType callback.
- [x] Merge six-row, below-cursor completion options into `legacy-coding.lua`.
- [x] Verify notebook wheel navigation, existing viewport adjustment, and ordinary buffer isolation using real notebook models.

### Task 3: Validation and documentation

- [x] Verify actual IPython inspection output for Linear and train_test_split using the installed Conda environment.
- [x] Exercise automatic help and floating window geometry with an embedded Neovim and a controlled kernel response.
- [x] Update README with the new behavior and limitations; run regression tests, Lua parsing, and diff checks.
- [x] Review final changes and report backup path plus any live-kernel validation limits.

## Completion record

- Backup: `/home/pinocchio/nvim-backups/notebook-20261113-215429`.
- `nvim --clean --headless -i NONE -l tests/notebook_signature.lua`: passed conversion, call detection, RPC forwarding, native-provider isolation, stale replies, and delayed keymap installation.
- Actual Conda IPython inspection output: Linear, train_test_split, and BCEWithLogitsLoss parsed with complete signatures and documentation.
- Embedded Neovim UI: passed at 100x32 and 80x24; existing-call InsertEnter opens hints above, menu below with six rows, both Ctrl+K callbacks use Noice, wheel leaves cell editing, ordinary Python buffers receive no notebook mappings.
- Delayed Noice response after switching buffers: no stale signature appears.
- Full configuration startup passed with merged cmp/Noice options and JupynvimOpen. The sandbox-only Mason EPERM did not occur when the startup check ran with access to its existing working files.
- Lua syntax and git diff whitespace checks passed. Existing path_completion.lua, notebook_view.lua, and lazy-lock.json match their pre-task backup byte for byte.
- No user notebook or running kernel was modified. A live notebook kernel round trip was not tested; UI tests use controlled kernel responses with actual IPython documentation.

### Review adjustments

1. Disable jupynvim's enter_output_up default through its supported keymap option: delayed binding otherwise overwrites normal Ctrl+K. Reproduced before fixing; the 400ms regression check now passes.
2. Resolve enclosing call positions for all adapted signature requests: manual Ctrl+K over an argument otherwise inspects the argument. A regression check failed before fixing and now passes.
3. Validate adapted replies against buffer, changedtick, call position, and mode before forwarding: Noice's automatic path otherwise bypasses auto_help guards. An edit/buffer-switch regression check failed before fixing and now passes.

These are narrow compatibility corrections to the supplied implementation. Native signature providers and ordinary hover requests are preserved. Independent read-only review found no additional important defects. No deferred minor findings.
