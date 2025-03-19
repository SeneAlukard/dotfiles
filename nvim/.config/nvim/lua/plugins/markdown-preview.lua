return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }, -- Commands to load the plugin
  build = "npm install",                                                       -- Use npm to install dependencies
  ft = { "markdown" },                                                         -- File types to load the plugin for
  config = function()
    -- Plugin settings
    vim.g.mkdp_browser = 'firefox' -- Set your preferred browser
    vim.g.mkdp_theme = 'dark'      -- Match GitHub's dark theme
    vim.g.mkdp_auto_start = 0      -- Disable auto-start
    vim.g.mkdp_auto_close = 1      -- Auto-close preview when switching buffers
    vim.g.mkdp_refresh_slow = 0    -- Faster refresh

    -- Keybindings
    vim.keymap.set("n", "<leader>mdn", ":MarkdownPreview<CR>", { desc = "Start Markdown Preview" })
    vim.keymap.set("n", "<leader>mds", ":MarkdownPreviewStop<CR>", { desc = "Stop Markdown Preview" })
    vim.keymap.set("n", "<leader>mdt", ":MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })
  end
}

