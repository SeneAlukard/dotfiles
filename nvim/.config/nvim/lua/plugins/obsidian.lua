return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
    },

    -- UI minimization settings
    disable_frontmatter = true, -- Don't show frontmatter in preview
    completion = {
      nvim_cmp = true,          -- Use regular nvim-cmp instead of Obsidian's UI
      min_chars = 2,            -- Reduce popup frequency
    },

    -- Disable most UI elements
    ui = {
      enable = false, -- Disable all built-in UI
      checkboxes = {
        enabled = false,
      },
    },

    -- Optional: Disable specific features
    daily_notes = {
      enabled = false,
    },
    templates = {
      enabled = false,
    },

    -- Performance optimizations
    follow_url_func = function(url)
      -- Use default handler instead of Obsidian's UI
      vim.fn.jobstart({ "xdg-open", url }) -- or "open" on macOS
    end,
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    -- Additional keymaps to manually trigger features when needed
    vim.keymap.set("n", "<leader>oc", "<cmd>ObsidianCheck<CR>", { desc = "Obsidian: Check links" })
    vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { desc = "Obsidian: Today's note" })
  end
}
