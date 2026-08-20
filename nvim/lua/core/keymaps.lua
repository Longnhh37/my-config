-- =============================================================================
-- core/keymaps.lua  –  Global keymaps  (leader = <Space>)
-- =============================================================================
-- GENERAL:
--   n  <leader>w      :w  save file
--   n  <Esc>          clear search highlight (nohlsearch)
--   v  J              move visual selection down
--   v  K              move visual selection up
--
-- CHANGE (no yank):
--   n  c              "_c    change (black-hole register)
--   x  c              "_c    change selection
--   n  cc             "_cc   change line
--   n  C              "_C    change to EOL
--
-- DELETE (no yank):
--   n  <leader>x      "_d    delete with motion
--   n  x              "_x    delete char
--   n  X              "_dd   delete line  (⚠ overrides vim default X = del char before cursor)
--   n  <M-x>          "_D    delete till end of line
--   n  <M-X>          "_dG   delete to EOF
--   n  <x=>           "%d    wipe entire buffer
--   x  x              "_d    delete selection
--
-- TERMINAL:
--   t  <Esc><Esc>     exit terminal mode
--
-- WINDOW RESIZE:
--   n  <C-Up/Down>    resize height ±10
--   n  <C-Left/Right> resize width  ±10
--
-- NAVIGATION (line):
--   n  gh             ^   jump to first non-blank char of line
--   n  gl             $   jump to end of line
--
-- INSERT MODE :
--   Clip:   <C-v> paste from system clipboard
--
-- =============================================================================

vim.g.mapleader = " "

local map = vim.keymap.set

-- ── General ───────────────────────────────────────────────────────────────────
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<Esc>", ":nohlsearch<CR><Esc>", { silent = true, desc = "Clear search highlight" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<C-d>", "<C-d>zz", { desc = "Centered window when scroll down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Centered window when scroll up" })

map("n", "n", "nzz")
map("n", "N", "Nzz")

map("x", "p", '"_dP')

-- ── Undo/redo ────────────────────────────────────────────────────
map("n", "U", "<C-r>")
map("n", "u", "u")

-- ── Entire buffer operation ────────────────────────────────────────────────────
map("n", "d=", "ggVGd")
map("n", "y=", "ggVGy")
map("n", "x=", 'ggVG"_d')
map("n", "c=", "ggVGc")
map("n", "v=", "ggVG")
map("n", "g=", "gg=G")

-- ── Change without yanking ────────────────────────────────────────────────────
map("n", "c", '"_c', { desc = "Change (no yank)" })
map("x", "c", '"_c', { desc = "Change selection (no yank)" })
map("n", "cc", '"_cc', { desc = "Change line (no yank)" })
map("n", "C", '"_C', { desc = "Change to EOL (no yank)" })

-- ── Delete without yanking ────────────────────────────────────────────────────
-- Remap x → "_d family to avoid polluting the unnamed register.
map("n", "<leader>x", '"_d', { noremap = true, silent = true, desc = "Delete (no yank)" })
map("n", "x", '"_x', { desc = "Delete char (no yank)" })
map("n", "X", '"_dd', { desc = "Delete line (no yank)" })
map("n", "<M-x>", '"_d$', { noremap = true, desc = "Delete till line end" })
map("n", "<M-X>", '"_dG', { desc = "Delete to EOF (no yank)" })
map("x", "x", '"_d', { desc = "Delete selection (no yank)" })

-- ── Terminal ──────────────────────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Window resizing ───────────────────────────────────────────────────────────
map("n", "<C-Up>", ":resize -10<CR>", { desc = "Decrease window height" })
map("n", "<C-Down>", ":resize +10<CR>", { desc = "Increase window height" })
map("n", "<C-Left>", ":vertical resize -10<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +10<CR>", { desc = "Increase window width" })

-- ── Line navigation ──────────────────────────────────────────────────────────
map("n", "gh", "^", { desc = "Line start (first non-blank)" })
map("n", "gl", "$", { desc = "Line end" })

-- ── Clipboard ────────────────────────────────────────────────────────────
-- Ctrl + V → paste from system clipboard (no auto-indent mess)
map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste from clipboard" })

-- ── Tab management ────────────────────────────────────────────────────────────
map("n", "<leader>Tn", ":tabnew<CR>", { desc = "Tab: new" })
map("n", "<leader>Tc", ":tabclose<CR>", { desc = "Tab: close" })
map("n", "<leader>To", ":tabonly<CR>", { desc = "Tab: close others" })
map("n", "]T", ":tabnext<CR>", { desc = "Tab: next" })
map("n", "[T", ":tabprev<CR>", { desc = "Tab: prev" })
map("n", "<leader>T1", "1gt", { desc = "Tab: go to 1" })
map("n", "<leader>T2", "2gt", { desc = "Tab: go to 2" })
map("n", "<leader>T3", "3gt", { desc = "Tab: go to 3" })
-- move tab left/right
map("n", "<leader>T<", ":tabmove -1<CR>", { desc = "Tab: move left" })
map("n", "<leader>T>", ":tabmove +1<CR>", { desc = "Tab: move right" })
