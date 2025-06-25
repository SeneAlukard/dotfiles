return {
  "nvim-lualine/lualine.nvim",
  dependencies = { 
    "nvim-tree/nvim-web-devicons",
    "folke/tokyonight.nvim" -- Add this as an explicit dependency
  },
  config = function()
    -- First check if tokyonight is available
    local status_ok, _ = pcall(require, "tokyonight")
    local theme = status_ok and "tokyonight" or "auto"
    
    require("lualine").setup({
      options = {
        theme = theme,
        icons_enabled = true,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true, -- Use global statusline if Neovim 0.7+
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 
          {
            'mode', 
            fmt = function(str) return str:sub(1,1) end -- Show only first character of mode
          }
        },
        lualine_b = { 
          {
            'branch',
            icon = '',
          },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            diff_color = {
              added = { fg = '#98be65' },
              modified = { fg = '#ECBE7B' },
              removed = { fg = '#ec5f67' },
            },
          },
          'diagnostics'
        },
        lualine_c = { 
          {
            'filename',
            path = 1, -- Show relative path
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
              newfile = '[New]',
            }
          }
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { 'nvim-tree', 'toggleterm', 'fugitive' }
    })
  end,
}
