--Setting for NVIM--
vim.cmd("set expandtab")

vim.cmd("set tabstop=2")

vim.cmd("set softtabstop=2")

vim.cmd("set shiftwidth=2")

vim.cmd("set number")

vim.cmd("set relativenumber")

-- init.lua
vim.api.nvim_set_keymap('n', 'y', '"ay', { noremap = true })
vim.api.nvim_set_keymap('v', 'y', '"ay', { noremap = true })
vim.api.nvim_set_keymap('n', 'Y', '"aY', { noremap = true })
vim.api.nvim_set_keymap('v', 'Y', '"aY', { noremap = true })
vim.api.nvim_set_keymap('n', 'p', '"ap', { noremap = true })
vim.api.nvim_set_keymap('v', 'p', '"ap', { noremap = true })
vim.api.nvim_set_keymap('n', 'P', '"aP', { noremap = true })
vim.api.nvim_set_keymap('v', 'P', '"aP', { noremap = true })

