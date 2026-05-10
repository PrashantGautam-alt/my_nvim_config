-- my keymaps
-- i try to keep this simple and only add stuff i actually use

local map = vim.keymap.set

-- leader key is space, this needs to be set before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable netrw because i use neo-tree for file browsing
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


-- clipboard stuff
-- by default nvim has its own clipboard that doesnt talk to the system
-- these two let me copy/paste with the actual system clipboard

map({ "n", "x" }, "gy", '"+y', { desc = "copy to system clipboard" })
map({ "n", "x" }, "gp", '"+p', { desc = "paste from system clipboard" })


-- delete without messing up what i copied
-- normally x and d overwrite the yank register which is annoying
-- _ is the blackhole register, stuff goes in and never comes out

map({ "n", "x" }, "x", '"_x', { desc = "delete char (dont yank it)" })
map({ "n", "x" }, "X", '"_d', { desc = "delete (dont yank it)" })


-- navigation
-- 0 goes to start of line so i made 1 go to end, feels natural to me
map({ "n", "x" }, "1", "$", { desc = "go to end of line" })

-- j and k by default skip over wrapped lines which is annoying for long lines
map("n", "j", "gj", { desc = "move down through wrapped lines" })
map("n", "k", "gk", { desc = "move up through wrapped lines" })

-- keep search results in the middle of the screen
-- without this the result can appear anywhere and i lose track of it
map("n", "n", "nzzzv", { desc = "next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "prev search result (centered)" })

-- press esc to clear the search highlight after im done searching
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "clear search highlight" })


-- terminal
-- opens a terminal in a horizontal split below
map("n", "<Leader>t", ":sp | terminal<CR>", { desc = "open terminal below" })

-- by default you exit terminal mode with ctrl+\ ctrl+n which is horrible
-- esc is way more natural
map("t", "<Esc>", "<C-\\><C-n>", { desc = "exit terminal mode" })


-- moving between splits
-- instead of doing ctrl+w and then h/j/k/l every time
map("n", "<C-h>", "<C-w>h", { desc = "go to left split" })
map("n", "<C-l>", "<C-w>l", { desc = "go to right split" })
map("n", "<C-j>", "<C-w>j", { desc = "go to split below" })
map("n", "<C-k>", "<C-w>k", { desc = "go to split above" })

-- resize splits with arrow keys
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "make split taller" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "make split shorter" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "make split narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "make split wider" })


-- buffer navigation
-- tab and shift+tab to go through open buffers
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "prev buffer" })
map("n", "<Leader>bd", "<cmd>bdelete<CR>", { desc = "close this buffer" })
