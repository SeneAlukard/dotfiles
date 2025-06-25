return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      -- Basic DAP setup
      local dap = require("dap")
      local dapui = require("dapui")

      -- C/C++ configuration
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.cpp = {
        {
          name = "Launch current file",
          type = "codelldb",
          request = "launch",
          program = function()
            local basename = vim.fn.expand('%:t:r')
            local filepath = vim.fn.expand('%:p:h')
            return filepath .. '/' .. basename .. '.out'
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- ===== Enhanced Keybindings =====

      -- Core debugging movement (keeping your existing shortcuts)
      vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "Debug: Step Out" })

      -- Breakpoint management
      vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Conditional Breakpoint" })

      -- Additional breakpoint commands
      vim.keymap.set("n", "<leader>dbl", function()
        dap.list_breakpoints()
      end, { desc = "Debug: List Breakpoints" })

      vim.keymap.set("n", "<leader>dbr", function()
        dap.clear_breakpoints()
      end, { desc = "Debug: Clear All Breakpoints" })

      -- Session control
      vim.keymap.set("n", "<leader>dtr", function() dap.restart() end, { desc = "Debug: Restart Session" })
      vim.keymap.set("n", "<leader>dtc", function() dap.terminate() end, { desc = "Debug: Terminate Session" })

      -- Information display
      vim.keymap.set("n", "<leader>dh", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Debug: Hover Variables" })

      vim.keymap.set("n", "K", function()
        if dap.session() then
          require("dap.ui.widgets").hover()
        else
          vim.lsp.buf.hover()
        end
      end, { desc = "Hover (LSP or Debug)" })

      -- REPL (Read-Eval-Print Loop)
      vim.keymap.set("n", "<leader>dro", function() dap.repl.open() end, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>drl", function() dap.repl.run_last() end, { desc = "Debug: Run Last REPL Command" })

      -- Frame navigation (corrected functions)
      vim.keymap.set("n", "<leader>dfn", function()
        dap.down() -- This is the correct function for next frame
      end, { desc = "Debug: Next Frame" })

      vim.keymap.set("n", "<leader>dfp", function()
        dap.up() -- This is the correct function for previous frame
      end, { desc = "Debug: Previous Frame" })

      -- UI controls
      vim.keymap.set("n", "<leader>dui", function()
        dapui.toggle()
      end, { desc = "Debug: Toggle UI" })

      vim.keymap.set("n", "<leader>de", function()
        dapui.eval()
      end, { desc = "Debug: Evaluate Expression" })

      vim.keymap.set("v", "<leader>de", function()
        dapui.eval()
      end, { desc = "Debug: Evaluate Selection" })

      -- DAP UI setup
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Auto open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
  },

  -- The rest of your configuration remains the same
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb" },
        automatic_installation = true,
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
  },
  {
    "nvim-telescope/telescope-dap.nvim",
    event = "VeryLazy", -- Important: Load after everything else
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("telescope").load_extension("dap")
    end,
  },
}
