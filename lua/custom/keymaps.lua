local keymap = vim.keymap

--General Custom Keymaps
--
--window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

--tab managment
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

--yanking management
keymap.set("n", "<M-c>", '"+y', { desc = "Yank to system clipboard", silent = true })
keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard", silent = true })
keymap.set("v", "<M-c>", '"+y', { desc = "Yank to system clipboard", silent = true })
keymap.set("v", "x", '"_x', { desc = "Delete without yanking", silent = true })
keymap.set("n", "x", '"_x', { desc = "Delete without yanking", silent = true })
keymap.set("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { silent = true, desc = "Don't copy replaced text" })

--insert mode management
keymap.set("i", "<C-h>", "<Left>", { desc = "Move left", silent = true })
keymap.set("i", "<C-l>", "<Right>", { desc = "Move right", silent = true })
keymap.set("i", "<C-j>", "<Down>", { desc = "Move down", silent = true })
keymap.set("i", "<C-k>", "<Up>", { desc = "Move up", silent = true })

-- Move selected block up
keymap.set("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move block up" })

-- Move selected block down
keymap.set("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move block down" })
