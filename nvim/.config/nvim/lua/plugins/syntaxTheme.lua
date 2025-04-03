return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,    -- Load immediately
    priority = 1000, -- Highest priority
    config = function()
      require("kanagawa").setup({
        theme = "wave", -- Options: "wave" (default), "dragon", "lotus"
        transparent = false, -- Set to true for transparency
      })
      vim.cmd.colorscheme("kanagawa") -- Apply on startup
    end,
  }
}
