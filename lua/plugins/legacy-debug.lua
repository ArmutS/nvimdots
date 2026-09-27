return {
  {
    name = "legacy-dap-adapters",
    dir = vim.fn.stdpath("config") .. "/lua/legacy-dap-adapters",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local mason = vim.fn.stdpath("data") .. "/mason/packages"

      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = mason .. "/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
      }
      dap.adapters.bashdb = {
        type = "executable",
        command = mason .. "/bash-debug-adapter/bash-debug-adapter",
        name = "bashdb",
      }

      local cpp_launch = {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
      }
      local cpp_attach = {
        name = "Attach to gdbserver :1234",
        type = "cppdbg",
        request = "launch",
        MIMode = "gdb",
        miDebuggerServerAddress = "localhost:1234",
        miDebuggerPath = "/usr/bin/gdb",
        cwd = "${workspaceFolder}",
        program = cpp_launch.program,
      }
      dap.configurations.cpp = { cpp_launch, cpp_attach }
      dap.configurations.rust = { vim.deepcopy(cpp_launch), vim.deepcopy(cpp_attach) }
      dap.configurations.sh = {
        {
          type = "bashdb",
          request = "launch",
          name = "Launch file",
          showDebugOutput = true,
          pathBashdb = mason .. "/bash-debug-adapter/extension/bashdb_dir/bashdb",
          pathBashdbLib = mason .. "/bash-debug-adapter/extension/bashdb_dir",
          trace = true,
          file = "${file}",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pathCat = "cat",
          pathBash = "/bin/bash",
          pathMkfifo = "mkfifo",
          pathPkill = "pkill",
          args = {},
          argsString = "",
          env = {},
          terminalKind = "integrated",
        },
      }
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local mason_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      local python = vim.fn.executable(mason_python) == 1 and mason_python or vim.fn.exepath("python3")
      require("dap-python").setup(python)
    end,
  },
}
