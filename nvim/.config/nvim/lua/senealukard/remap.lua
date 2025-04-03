vim.g.mapleader = " "

vim.g.maplocalleader = "\\"

-- vim.api.nvim_set_keymap('n', '<leader>pv',':Ex<CR>', {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '<leader>pv', '<CMD>Oil<CR>', {})

vim.api.nvim_set_keymap('n', '<C-j>', '<cmd>lua require("harpoon.ui").nav_prev()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua require("harpoon.ui").nav_next()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-w>', '<cmd>lua require("harpoon.mark").add_file()<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-d>', '<cmd>lua require("harpoon.mark").rm_file()<CR>', { noremap = true, silent = true })


-- Window navigation with leader+w prefix
vim.api.nvim_set_keymap('n', '<leader>wh', '<C-w>h', { noremap = true, silent = true }) -- Move to left split
vim.api.nvim_set_keymap('n', '<leader>wl', '<C-w>l', { noremap = true, silent = true }) -- Move to right split
vim.api.nvim_set_keymap('n', '<leader>wj', '<C-w>j', { noremap = true, silent = true }) -- Move to bottom split
vim.api.nvim_set_keymap('n', '<leader>wk', '<C-w>k', { noremap = true, silent = true }) -- Move to top split


-- Using Ctrl+c to center screen on cursor
vim.api.nvim_set_keymap('n', '<C-c>', 'zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>vs', ':vsplit<CR>', { noremap = true, silent = true })
