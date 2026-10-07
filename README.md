# Neovim dots

My Neovim configuration uses LazyVim and keeps Omarchy's active colorscheme in sync. The `lua/plugins/theme.lua` symlink expects the repo to be installed at `~/.config/nvim` on Omarchy.

```sh
git clone git@github.com:ArmutS/nvimdots.git ~/.config/nvim
nvim
```

LazyVim installs plugins on first launch. For notebook support, create the Python provider used by `lua/config/options.lua`:

```sh
python3 -m venv ~/.local/share/nvim/python-provider
~/.local/share/nvim/python-provider/bin/python -m pip install pynvim jupyter_client jupytext ipykernel nbformat
```

Then run `:UpdateRemotePlugins` in Neovim once. Mason manages the configured language servers, formatters, linters, and debug adapters.

Language tooling is limited to Python (Jedi, Ruff, debugpy), Rust (rust-analyzer, rustfmt, C++ debugger), C/C++ (clangd, clang-format, C++ debugger), JavaScript (TypeScript language server, Prettier), HTML (HTML language server, Prettier), and CSV (syntax highlighting). Rust formatting uses `rustfmt` from the Rust toolchain, and C/C++ uses the system `clangd`. CSV has no separate language server or formatter.

For each project virtual environment used with notebooks, install `ipykernel` in that environment. Opening an `.ipynb` while the venv is active registers and starts its kernel automatically. `Shift+Enter` runs a cell and moves to the next one; `<leader>X` runs the current cell. Outputs remain visible below cells and are saved back to the notebook. Matplotlib and Seaborn PNG plots use `image.nvim` with foot's Sixel support, so ImageMagick must be installed.

In normal mode, `<leader>rp` saves and runs the current Python file in a bottom terminal split. It uses the virtual environment active when Neovim started (`VIRTUAL_ENV` or `CONDA_PREFIX`), falling back to the startup PATH's Python if no environment is active. Relative paths use Neovim's current working directory (`:pwd`).

Path completion uses that same working directory: type `pd.read_csv("temp/` to suggest files inside `temp`, or `pd.read_csv("./` to suggest folders and files in the working directory. Accept with `Tab`; directory completions include `/` so you can continue browsing. Use `Ctrl+Space` to request completion manually.

The legacy plugins are adapted under `lua/plugins/legacy-*.lua`. Omarchy theme integration and the existing LazyVim structure remain in place.
