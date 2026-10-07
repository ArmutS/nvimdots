return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = { automatic_installation = false },
  },
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
