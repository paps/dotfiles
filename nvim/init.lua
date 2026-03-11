-- show tabs and trailing spaces
vim.opt.list = true
vim.opt.listchars = { tab = "¦ ", trail = "·" }

-- default indentation
vim.opt.tabstop = 4 -- number of columns a tab counts for (this is the only command affecting text display)
vim.opt.softtabstop = 4 -- number of columns inserted when hitting tab in insert mode (should be equal to tabstop)
vim.opt.shiftwidth = 4 -- number of columns removed or inserted when hitting << and >> (should be equal to tabstop)
vim.opt.preserveindent = true
vim.opt.copyindent = true

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true -- ignore case when searching only in lowercase

-- layout
vim.opt.number = false -- don't show line numbers (I like being able to copy text with the terminal selection)
vim.opt.splitright = true -- open vertical splits to the right
vim.opt.splitbelow = true -- open horizontal splits below

-- statusline
-- Claude-generated minimal imitation of what would have been done by the airline external plugin in the past
if not vim.g.vscode then
	local mode_config = {
		n = { label = "NORMAL",  hl = "StlModeNormal" },
		i = { label = "INSERT",  hl = "StlModeInsert" },
		v = { label = "VISUAL",  hl = "StlModeVisual" },
		V = { label = "V-LINE",  hl = "StlModeVisual" },
		["\22"] = { label = "V-BLOCK", hl = "StlModeVisual" },
		R = { label = "REPLACE", hl = "StlModeReplace" },
		c = { label = "COMMAND", hl = "StlModeCommand" },
		t = { label = "TERMINAL", hl = "StlModeInsert" },
	}
	-- set some 'semantic' colors based on the current theme (not important, it's just to have the mode change color)
	vim.api.nvim_set_hl(0, "StlModeNormal",  { link = "CurSearch" })
	vim.api.nvim_set_hl(0, "StlModeInsert",  { link = "DiffAdd" })
	vim.api.nvim_set_hl(0, "StlModeVisual",  { link = "Visual" })
	vim.api.nvim_set_hl(0, "StlModeReplace", { link = "DiffDelete" })
	vim.api.nvim_set_hl(0, "StlModeCommand", { link = "WarningMsg" })
	function Statusline()
		local m = mode_config[vim.fn.mode()] or { label = vim.fn.mode(), hl = "StlModeNormal" }
		local file = vim.fn.expand("%:f")
		if file == "" then file = "[No Name]" end
		local modified = vim.bo.modified and " [+]" or ""
		local readonly = vim.bo.readonly and " [RO]" or ""
		local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "none"
		local pos = string.format("%d:%d %d%%%%", vim.fn.line("."), vim.fn.col("."), math.floor(vim.fn.line(".") * 100 / math.max(vim.fn.line("$"), 1)))
		return "%#" .. m.hl .. "# " .. m.label .. " %#StatusLine# " .. file .. modified .. readonly .. "%=" .. ft .. "  " .. pos .. " "
	end
	vim.opt.statusline = "%!v:lua.Statusline()"
end

-- other stuff
vim.opt.wrap = false -- do not wrap long lines initially (use <Space>w to toggle)
vim.opt.scrolloff = 3 -- offset of 3 lines around the cursor
vim.opt.undofile = true -- persist undo history to disk so it survives closing and reopening files
vim.opt.modelines = 0 -- disable modelines (special vim comments in files) to avoid security exploits
vim.opt.cursorline = true -- highlight current line
vim.opt.equalalways = false -- don't auto-resize windows on split/close
vim.opt.timeoutlen = 3000 -- compose real commands for 3 seconds
vim.opt.ttimeoutlen = 0 -- don't compose insert mode commands (escape, etc)
vim.opt.shortmess:append("I") -- don't care about intro text

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

-- disable ex mode (legacy thing from the 80s)
vim.keymap.set("", "Q", "<NOP>")

-- make :W work like :w, same for :Q, etc (shitty typing skills!)
vim.cmd([[
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev E e
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev Wqa wqa
cnoreabbrev WQa wqa
cnoreabbrev WQA wqa
cnoreabbrev q1 q!
cnoreabbrev qa1 qa!
cnoreabbrev Qa1 qa!
cnoreabbrev QA1 qa!
cnoreabbrev w1 w!
cnoreabbrev W1 w!
cnoreabbrev wq1 wq!
cnoreabbrev Wq1 wq!
cnoreabbrev WQ1 wq!
cnoreabbrev wqa1 wqa!
cnoreabbrev Wqa1 wqa!
cnoreabbrev WQa1 wqa!
cnoreabbrev WQA1 wqa!
]])

-- tab navigation
-- ctrl-k for next tab, ctrl-j for previous tab
vim.keymap.set("", "<C-j>", "<Cmd>tabprevious<CR>")
vim.keymap.set("", "<C-k>", "<Cmd>tabnext<CR>")
-- ctrl-t for new tab
vim.keymap.set("n", "<C-t>", "<Cmd>tabnew<CR>")

-- some useful <Leader> shortcuts
vim.keymap.set("", "<Leader>j", "<Cmd>nohlsearch<CR>")
vim.keymap.set("", "<Leader>w", "<Cmd>set wrap!<CR>")

-- file browser
if not vim.g.vscode then
	vim.keymap.set("", "<Leader>n", "<Cmd>Lexplore<CR>")
	-- netrw "sidebar-ish" defaults
	vim.g.netrw_banner = 0 -- hide banner
	vim.g.netrw_liststyle = 3 -- tree view
	vim.g.netrw_winsize = 25 -- sidebar width (%)
	-- behavior when opening a file from netrw:
	--   0 = reuse window,
	--   1 = horizontal,
	--   2 = vertical,
	--   3 = new tab,
	--   4 = open in previous window (so if netrw is in a sidebar, open in main area)
	vim.g.netrw_browse_split = 4
	-- make 'o' behave like in nerdtree, i.e. same as Enter in netrw
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "netrw",
		callback = function()
			vim.keymap.set("n", "o", "<CR>", { buffer = true, remap = true })
		end,
	})
end