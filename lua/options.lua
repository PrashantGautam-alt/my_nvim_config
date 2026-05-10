
--watch Vhyrro's yt playlist on neovim 
--some basics functions :
--use :help vim.opt for the descriptions of each options
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = "unnamedplus"

vim.opt.scrolloff = 999

vim.opt.virtualedit = "block" 

--shows the changes you are about to make with %s in a nice split box at the bottom!!
vim.opt.inccommand = "split"

--helpful when you want to tab search for plugins which begin with uppercase in nvim 
vim.opt.ignorecase = true

vim.opt.termguicolors = true 

vim.g.mapleader = " "

--vim.keymap.set({'n', 'x'}, 'gy', '"+y')--copy to clip using gy 
--vim.keymap.set({'n', 'x'}, 'gp', '"+p')--paste from clip using gp
----delete text w/o changing the registers
--vim.keymap.set({'n', 'x'}, 'x', '"_x')
--vim.keymap.set({'n', 'x'}, 'X', '"_d')
--
----some useful keymaps
--
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1
--
--vim.keymap.set({'n'}, "00", "$", { desc = "Go to end of line" })
--
--
