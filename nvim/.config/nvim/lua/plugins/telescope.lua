return  {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function()
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>pf', builtin.find_files, {})

      vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
      defaults = {
        file_browser = {
          cmd = vim.fn.expand('%:p:h'),
          hidden = true,
        },
      }
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
          }
        },
        find_files = {
          hidden = true,
          find_command = {
            "rg",
            "--files",
            "--glob",
            "!{.git/*,.next/*}",
            "/",
          }
        }
      }
      require("telescope").load_extension("ui-select")
    end
  }
}



