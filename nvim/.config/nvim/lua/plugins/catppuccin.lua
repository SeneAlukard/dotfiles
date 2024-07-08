return {
  "catppuccin/nvim", 
  name = "catppuccin", 
  priority = 1000,
  config = function()
    vim.api.nvim_command('colorscheme catppuccin')
  end
}

  
