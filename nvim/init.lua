-- disable netrw before loading plugins (because using nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- default indentation (putting this before guess-indent just in case)
vim.opt.tabstop = 4 -- number of columns a tab counts for (this is the only command affecting text display)
vim.opt.softtabstop = 4 -- number of columns inserted when hitting tab in insert mode (should be equal to tabstop)
vim.opt.shiftwidth = 4 -- number of columns removed or inserted when hitting << and >> (should be equal to tabstop)

-- plugins
vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/NMAC427/guess-indent.nvim" },
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/dlyongemallo/diffview-plus.nvim" },
})

-- plugin setup
require("gitsigns").setup()
require("nvim-tree").setup({
	renderer = {
		icons = {
			web_devicons = {
				-- make the file tree less distracting, it's not supposed to be the center of the attention
				file = { color = false },
				folder = { color = false },
			},
		},
	},
	filters = {
		-- by default, git ignored files are not shown, which is crazy...
		git_ignored = false,
		-- show all dotfiles
		dotfiles = false,
	},
})
require("lualine").setup()
require("guess-indent").setup()

-- add a bit of color to git changes indicators
vim.cmd([[
  highlight! link NvimTreeGitDirtyIcon   DiagnosticOk
  highlight! link NvimTreeGitNewIcon     DiagnosticInfo
  highlight! link NvimTreeGitStagedIcon  DiagnosticOk
  highlight! link NvimTreeGitDeletedIcon DiagnosticError
  highlight! link NvimTreeGitMergeIcon   DiagnosticError
  highlight! link NvimTreeGitRenamedIcon DiagnosticInfo
]])

-- show tabs, trailing spaces, non-breaking spaces and off-screen continuations
vim.opt.list = true
vim.opt.listchars = { tab = "¦ ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true -- ignore case when searching only in lowercase

-- layout
vim.opt.number = true -- don't show line numbers (I like being able to copy text with the terminal selection)
vim.opt.splitright = true -- open vertical splits to the right
vim.opt.splitbelow = true -- open horizontal splits below

-- other stuff
vim.opt.wrap = false -- do not wrap long lines initially (use <Space>w to toggle)
vim.opt.linebreak = true -- when wrapping, break at word boundaries instead of mid-word
vim.opt.scrolloff = 3 -- offset of 3 lines around the cursor
vim.opt.undofile = true -- persist undo history to disk so it survives closing and reopening files
vim.opt.modelines = 0 -- disable modelines (special vim comments in files) to avoid security exploits
vim.opt.cursorline = true -- highlight current line
vim.opt.equalalways = false -- don't auto-resize windows on split/close
vim.opt.timeoutlen = 3000 -- compose real commands for 3 seconds
vim.opt.ttimeoutlen = 0 -- don't compose insert mode commands (escape, etc)

-- auto-reload files changed outside of nvim (autoread is on by default, but
-- nothing checks file timestamps unless we ask, so poll with a timer)
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(2000, 2000, vim.schedule_wrap(function()
	-- checktime is not allowed in the cmdline-window or while typing a command
	if vim.fn.getcmdwintype() == "" and vim.fn.mode() ~= "c" then
		vim.cmd("silent! checktime")
	end
end))

-- if running in a docker sandbox in tmux over ssh, use the tmux clipboard
-- (because in that situation it works to access the host's clipboard)
if vim.env.SANDBOX_ID and vim.env.SSH_TTY and vim.env.TMUX then
  vim.g.clipboard = "tmux"
end
-- yank and paste use system clipboard
vim.opt.clipboard = "unnamedplus"

-- leader key is space
vim.g.mapleader = " "

-- disable arrow keys
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
	vim.keymap.set({ "i", "" }, key, "<NOP>")
end

-- fast cursor movement instead of full page jumps
vim.keymap.set("", "<C-U>", "5k")
vim.keymap.set("", "<C-D>", "5j")

-- j/k move by display line when wrapping, except with a count (so 10j still
-- moves 10 real lines, keeping relative line number jumps accurate)
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- disable ex mode (legacy thing from the 80s)
vim.keymap.set("", "Q", "<NOP>")

-- make :W work like :w, same for :Q, etc (shitty typing skills!)
-- unlike a plain cnoreabbrev, only expand when it is the whole command typed
-- at a ':' prompt, so W/Q/etc stay untouched in search patterns and arguments
local function typo(lhs, rhs)
	vim.keymap.set("ca", lhs, function()
		return (vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs) and rhs or lhs
	end, { expr = true })
end
typo("W", "w")
typo("Q", "q")
typo("E", "e")
typo("Qa", "qa")
typo("QA", "qa")
typo("Wqa", "wqa")
typo("WQa", "wqa")
typo("WQA", "wqa")
typo("q1", "q!")
typo("qa1", "qa!")
typo("Qa1", "qa!")
typo("QA1", "qa!")
typo("w1", "w!")
typo("W1", "w!")
typo("wq1", "wq!")
typo("Wq1", "wq!")
typo("WQ1", "wq!")
typo("wqa1", "wqa!")
typo("Wqa1", "wqa!")
typo("WQa1", "wqa!")
typo("WQA1", "wqa!")

-- tab navigation
-- ctrl-k for next tab, ctrl-j for previous tab
vim.keymap.set("", "<C-j>", "<Cmd>tabprevious<CR>")
vim.keymap.set("", "<C-k>", "<Cmd>tabnext<CR>")
-- ctrl-t for new tab
vim.keymap.set("n", "<C-t>", "<Cmd>tabnew<CR>")

-- some useful <Leader> shortcuts
vim.keymap.set("", "<Leader>j", "<Cmd>nohlsearch<CR>")
vim.keymap.set("", "<Leader>w", "<Cmd>set wrap!<CR>")
vim.keymap.set("", "<Leader>n", "<Cmd>NvimTreeToggle<CR>")
