-- show tabs and trailing spaces
vim.opt.list = true
vim.opt.listchars = { tab = "¦ ", trail = "·" }

-- default indentation
vim.opt.tabstop = 4 -- number of columns a tab counts for (this is the only command affecting text display)
vim.opt.softtabstop = 4 -- number of columns inserted when hitting tab in insert mode (should be equal to tabstop)
vim.opt.shiftwidth = 4 -- number of columns removed or inserted when hitting << and >> (should be equal to tabstop)
-- adapt to the indentation style of files from other people: scan the first
-- lines and follow what the file already uses -- spaces of the smallest
-- indent seen, or tabs. Files with no indentation keep the settings above.
-- The detection is scheduled so it runs after ftplugins (which set their own
-- style, e.g. python), and skips files covered by a project .editorconfig
-- (built-in support), which knows better
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(ev)
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(ev.buf) then return end
			local ec = vim.b[ev.buf].editorconfig
			if ec and next(ec) ~= nil then return end
			local tabs, spaces, unit = 0, 0, 8
			for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, 500, false)) do
				if line:find("^\t") then
					tabs = tabs + 1
				else
					local n = #(line:match("^ +") or "")
					if n >= 2 then -- ignore 1-space indents, usually comment continuations
						spaces = spaces + 1
						unit = math.min(unit, n)
					end
				end
			end
			if spaces > tabs then
				vim.bo[ev.buf].expandtab = true
				vim.bo[ev.buf].shiftwidth = unit
				vim.bo[ev.buf].softtabstop = unit
			elseif tabs > 0 then
				vim.bo[ev.buf].expandtab = false
				vim.bo[ev.buf].shiftwidth = 0 -- 0 = follow tabstop, i.e. indent by whole tabs
				vim.bo[ev.buf].softtabstop = 0
			end
		end)
	end,
})

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
		local file = vim.fn.expand("%")
		if file == "" then file = "[No Name]" end
		file = file:gsub("%%", "%%%%") -- the returned string is a statusline format, escape '%' in filenames
		local modified = vim.bo.modified and " [+]" or ""
		local readonly = vim.bo.readonly and " [RO]" or ""
		local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "none"
		local pos = string.format("%d:%d %d%%%%", vim.fn.line("."), vim.fn.col("."), math.floor(vim.fn.line(".") * 100 / math.max(vim.fn.line("$"), 1)))
		-- inactive windows get the same line without the mode chip (during
		-- evaluation the "current" window is the one being drawn, and
		-- g:actual_curwin is the one really focused)
		if vim.api.nvim_get_current_win() ~= tonumber(vim.g.actual_curwin) then
			return " " .. file .. modified .. readonly .. "%=" .. ft .. "  " .. pos .. " "
		end
		local m = mode_config[vim.fn.mode()] or { label = vim.fn.mode(), hl = "StlModeNormal" }
		return "%#" .. m.hl .. "# " .. m.label .. " %#StatusLine# " .. file .. modified .. readonly .. "%=" .. ft .. "  " .. pos .. " "
	end
	-- %{%...%} (unlike %!...) is evaluated in the context of the window the
	-- statusline belongs to, so each window shows its own file and position
	vim.opt.statusline = "%{%v:lua.Statusline()%}"
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

-- auto-reload files changed outside of nvim (autoread is on by default, but
-- nothing checks file timestamps unless we ask, so poll with a timer)
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(2000, 2000, vim.schedule_wrap(function()
	-- checktime is not allowed in the cmdline-window or while typing a command
	if vim.fn.getcmdwintype() == "" and vim.fn.mode() ~= "c" then
		vim.cmd("silent! checktime")
	end
end))

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
	-- customize shortcuts, make it behave a bit like nerdtree
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "netrw",
		callback = function()
			-- make 'o' behave like in nerdtree, i.e. same as Enter in netrw
			vim.keymap.set("n", "o", "<CR>", { buffer = true, remap = true })
			-- 'r' and 'R' both refresh the listing instead of reversing sort order.
			-- :Explore re-lists in place; netrw's own refresh (<C-l>) is buggy.
			vim.keymap.set("n", "r", "<Cmd>Explore<CR>", { buffer = true })
			vim.keymap.set("n", "R", "<Cmd>Explore<CR>", { buffer = true })
			-- also fix the mouse: netrw opens on single click and maps double-click to
			-- "go up a directory" (!), so instead make single click only move the cursor
			-- and double click open like Enter
			vim.keymap.set("n", "<LeftMouse>", "<LeftMouse>", { buffer = true })
			vim.keymap.set("n", "<2-LeftMouse>", "<CR>", { buffer = true, remap = true })
		end,
	})
end
