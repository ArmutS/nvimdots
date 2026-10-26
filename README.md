# Neovim dots

My Neovim configuration uses LazyVim and keeps Omarchy's active colorscheme in sync. The `lua/plugins/theme.lua` symlink expects the repo to be installed at `~/.config/nvim` on Omarchy.

```sh
git clone git@github.com:ArmutS/nvimdots.git ~/.config/nvim
nvim
```

LazyVim installs plugins on first launch. Notebooks use [jupynvim](https://github.com/sheng-tse/jupynvim), pinned to v0.4.6. Its install hook downloads the matching Rust backend and verifies the release checksum. On platforms without a working prebuilt binary, it builds with Cargo. Neovim 0.11+ is required. Run `:checkhealth jupynvim` to check the installation.

Install `ipykernel` in each Python environment you want to use:

```sh
python -m pip install ipykernel
```

Jupynvim does not need a separate Python provider, Jupytext, Molten, or `:UpdateRemotePlugins`. Mason manages the configured language servers, formatters, linters, and debug adapters.

Language tooling is limited to Python (Jedi, Ruff, debugpy), Rust (rust-analyzer, rustfmt, C++ debugger), C/C++ (clangd, clang-format, C++ debugger), JavaScript (TypeScript language server, Prettier), HTML (HTML language server, Prettier), and CSV (syntax highlighting). Rust formatting uses `rustfmt` from the Rust toolchain, and C/C++ uses the system `clangd`. CSV has no separate language server or formatter.

Open an `.ipynb` directly, or create one with `:JupynvimOpen new-notebook.ipynb`. Jupynvim prefers a project-local `.venv` containing `ipykernel`; otherwise it uses the notebook's kernelspec and available kernels. Use `<leader>mi` or `:JupynvimKernel` to select another environment, including Conda kernels. `:w` saves code, Markdown, and outputs directly to the notebook.

Notebook completion and hover use jupynvim's kernel LSP, so start the kernel before requesting suggestions or documentation. Jedi stays enabled for ordinary `.py` files and is excluded from notebook buffers: its position requests on Markdown and output lines otherwise produce out-of-range errors. Notebook buffers therefore do not receive Jedi's static diagnostics or navigation.

Notebooks open in cell command mode: `j`/`k` select cells, `Enter` or `i` edits one, and `Esc` returns to cell command mode. `Shift+Enter` runs a cell and advances; `Ctrl+Enter` or `<leader>X` runs it without advancing. Existing shortcuts remain buffer-local: `<leader>x` runs and advances, `<leader>ma` runs all cells, `<leader>mb` runs the current cell and those below it, and `]h`/`[h` navigate cells. `:NotebookRunCell`, `:NotebookRunAll`, and `:NotebookRunBelow` remain available. `<leader>` is Space. Jupynvim's native `<leader>n` shortcuts are also available; `<leader>nb` adds a cell and `<leader>nm` converts it to Markdown.

Kitty and Ghostty 1.3+ automatically use inline graphics through the Kitty placeholder protocol. Other terminals, including foot, use Chafa's static ASCII rendering; install `chafa` (`sudo pacman -S chafa` on Arch/Omarchy). Sixel rendering is not supported by jupynvim. ImageMagick 7 is needed for animated GIFs. In tmux, enable `set -g allow-passthrough on` for inline graphics. Switch rendering manually with `:JupynvimImageMode placeholder` or `:JupynvimImageMode chafa`.

In normal mode, `<leader>rp` saves and runs the current Python file in a bottom terminal split. It uses the virtual environment active when Neovim started (`VIRTUAL_ENV` or `CONDA_PREFIX`), falling back to the startup PATH's Python if no environment is active. Relative paths use Neovim's current working directory (`:pwd`).

Path completion uses that same working directory: type `pd.read_csv("temp/` to suggest files inside `temp`, or `pd.read_csv("./` to suggest folders and files in the working directory. Accept with `Tab`; directory completions include `/` so you can continue browsing. Use `Ctrl+Space` to request completion manually.

The legacy plugins are adapted under `lua/plugins/legacy-*.lua`. Omarchy theme integration and the existing LazyVim structure remain in place.

`<leader>ac`, `<leader>cd`, and `:CodexToggle` show or hide Codex without stopping its process. `Ctrl+q` also hides the window. After exiting Codex or restarting Neovim, opening it runs `codex resume --last` to continue the most recent session in Neovim's working directory (`:pwd`); if none exists, Codex starts a new chat. Inside Codex, use `/resume` to choose an older saved session, `/rename` to give it a recognizable name, or `/new` when you explicitly want a new chat. The resume picker can show sessions from other directories too (use the key shown in its footer); from a shell, `codex resume --all` opens that list directly.
