vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

-- Reload files changed by external tools, such as OpenCode in tmux.
opt.autoread = true
opt.undofile = true
opt.confirm = true

-- enable notifs
vim.g.notifications_enabled = true

-- numbers
opt.relativenumber = true
opt.number = true

-- always show tabline
opt.showtabline = 2

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (Prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tabs to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.cursorline = true

-- colors
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift
opt.winborder = "rounded"

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom
opt.splitkeep = "screen"

-- turn off swapfile
opt.swapfile = false

-- update time
opt.updatetime = 200

-- scroll
opt.scrolloff = 3
opt.sidescrolloff = 3
