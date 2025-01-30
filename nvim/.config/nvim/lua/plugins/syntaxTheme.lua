-- return {
--   { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
--   {
--     "baliestri/aura-theme",
--     lazy = false,
--     priority = 1000,
--     config = function(plugin)
--       vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
--       vim.cmd([[colorscheme aura-dark-soft-text]])
--     end
--   }
-- }

return {
  "dracula/vim",
  dependencies = {
    "nvim-lualine/lualine.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    vim.opt.termguicolors = true
    vim.cmd.colorscheme("dracula")
    require("lualine").setup({
      options = { theme = "dracula" },
    })
  end,
}
