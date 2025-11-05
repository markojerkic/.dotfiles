local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function nme
local keymap = vim.keymap.set

-- These mappings control the size of splits (height/width)
keymap("n", "<M-,>", "<c-w>5<")
keymap("n", "<M-.>", "<c-w>5>")
keymap("n", "<M-+>", "<C-W>+")
keymap("n", "<M-->", "<C-W>-")

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)

keymap("n", "<C-e>", "<cmd>:Oil<CR>", opts)
keymap("n", "<S-e>", function()
    require("oil").open_float()
end, opts)

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Exit from visual block edit
keymap("i", "<C-c>", "<Esc>")

-- Up and down half page to center
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- After search, keep search term in the middle
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- Copy to system clipboard
keymap({ "n", "v" }, "<leader>y", [["+y]])
keymap("n", "<leader>Y", [["+Y]])
keymap("n", "<leader>cp", [["+p]])

-- Open a file in a new tab
keymap("n", "<leader>T", ":tabedit %<CR>", opts)
-- Tab navigations alt + number
keymap("n", "<A-1>", "1gt", opts)
keymap("n", "<A-2>", "2gt", opts)
keymap("n", "<A-3>", "3gt", opts)
keymap("n", "<A-4>", "4gt", opts)
keymap("n", "<A-5>", "5gt", opts)
keymap("n", "<A-6>", "6gt", opts)
keymap("n", "<A-7>", "7gt", opts)
keymap("n", "<A-8>", "8gt", opts)
keymap("n", "<A-9>", "9gt", opts)

-- Delete to void register
keymap({ "n", "v" }, "<leader>d", [["_d]])

keymap({ "n", "t" }, "<A-o>", function()
    require("marko.util.colors").toggleColouredPencils()
end)

-- Quickfix errors
-- keymap("n", "<C-k>", "<cmd>cnext<CR>zz")
-- keymap("n", "<C-j>", "<cmd>cprev<CR>zz")
keymap("n", "<leader>k", "<cmd>cnext<CR>zz")
keymap("n", "<leader>j", "<cmd>cprev<CR>zz")
-- keymap("n", "<leader>k", "<cmd>lnext<CR>zz")
-- keymap("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Replace the word under the cursor
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Search
keymap("n", "<leader>n", "<cmd>noh<CR>", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
