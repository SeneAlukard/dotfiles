vim.g.mapleader = " "

vim.g.maplocalleader = "\\"

-- vim.api.nvim_set_keymap('n', '<leader>pv',':Ex<CR>', {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '<leader>pv', '<CMD>Oil<CR>', {})

vim.api.nvim_set_keymap('n', '<C-j>', '<cmd>lua require("harpoon.ui").nav_prev()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua require("harpoon.ui").nav_next()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-w>', '<cmd>lua require("harpoon.mark").add_file()<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-d>', '<cmd>lua require("harpoon.mark").rm_file()<CR>', { noremap = true, silent = true })
