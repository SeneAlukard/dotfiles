--Lazy Package Manager Setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end


--Load Remap
vim.opt.rtp:prepend(lazypath)

--Load Lazy.nvim
require('senealukard.remap')


require('senealukard.lazy')

--Load Settings
require('senealukard.settings')

--Buffr Setup
require('senealukard.buffr')

require('senealukard.pscode')

require("senealukard.customfn")
