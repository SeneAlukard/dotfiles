return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        auto_trigger = true,
        -- Add the keymap table here:
        keymap = {
          accept = "<Tab>", -- Explicitly setting the default, or change to your preference
          -- Example: use Ctrl+L instead
          -- accept = "<C-l>",
          -- Example: use Enter to accept
          -- accept = "<CR>",
          dismiss = "<C-]>",   -- Default, good to keep or customize
          next = "<M-]>",      -- Default for next suggestion (Alt + ])
          prev = "<M-[>",      -- Default for previous suggestion (Alt + [)
          accept_word = false, -- Set a key if you want to accept word by word
          accept_line = false, -- Set a key if you want to accept the whole line
        }
      },
      panel = { -- It's good practice to also review/set panel keymaps if you use the panel
        enabled = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          open = "<M-CR>" -- Alt+Enter or Meta+Enter
        }
      },
      filetypes = {
        ["*"] = true, -- Enable for all filetypes
      },
      -- other copilot.lua options...
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = false,
    },
    -- If you want to set keymaps for CopilotChat, uncomment and modify its config block
    -- config = function(_, opts)
    --   require("CopilotChat").setup(opts)
    --   vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "CopilotChat - Toggle" })
    -- end,
  }
}
