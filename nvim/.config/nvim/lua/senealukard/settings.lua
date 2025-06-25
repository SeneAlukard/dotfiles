--Setting for NVIM--
vim.cmd("set expandtab")

vim.cmd("set tabstop=2")

vim.cmd("set softtabstop=2")

vim.cmd("set shiftwidth=2")

vim.cmd("set number")

vim.cmd("set relativenumber")

-- Enable list mode to show hidden characters
vim.opt.list = false

-- Customize how hidden characters are displayed
vim.opt.listchars = {
  tab = "> ", -- Show tabs as "> "
  space = ".", -- Show spaces as "...."
  trail = ".", -- Show trailing spaces as "."
  eol = "↲", -- Show end-of-line characters as "$"
  nbsp = "_", -- Show non-breaking spaces as "_"
  precedes = "<", -- Show characters that precede the visible text as "<"
  extends = ">", -- Show characters that extend beyond the visible text as ">"
}

-- Optional: Set a keybinding to toggle list mode on/off
vim.api.nvim_set_keymap('n', '<leader>l', ':set list!<CR>', { noremap = true, silent = true })

-- Optional: Customize the highlight color for hidden characters
vim.cmd([[highlight SpecialKey ctermfg=8 guifg=#555555]])
-- Optional: Customize the highlight color for hidden characters
vim.cmd([[highlight SpecialKey ctermfg=8 guifg=#555555]])


--Harpoon Settings
vim.cmd('highlight! HarpoonInactive guibg=NONE guifg=#63698c')
vim.cmd('highlight! HarpoonActive guibg=NONE guifg=white')
vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#7aa2f7')
vim.cmd('highlight! HarpoonNumberInactive guibg=NONE guifg=#7aa2f7')
vim.cmd('highlight! TabLineFill guibg=NONE guifg=white')
