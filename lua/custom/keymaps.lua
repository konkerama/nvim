-- Custom keymaps, functions, and autocmds

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=4 sts=4 sw=4 noet

-- Custom keybindings:
local function is_neotree_ft(ft)
	return type(ft) == "string" and ft:find("neo-tree", 1, true) ~= nil
end

vim.keymap.set("n", "<leader>e", function()
	if is_neotree_ft(vim.bo.filetype) then
		vim.cmd("wincmd p") -- jump back to previous (editor) window

		-- If the "previous" window is also Neo-tree (can happen with some Neo-tree UI states),
		-- fall back to the largest non-Neo-tree window in the current tab.
		if is_neotree_ft(vim.bo.filetype) then
			local best_win, best_width = nil, -1
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				local buf = vim.api.nvim_win_get_buf(win)
				if not is_neotree_ft(vim.bo[buf].filetype) then
					local width = vim.api.nvim_win_get_width(win)
					if width > best_width then
						best_win, best_width = win, width
					end
				end
			end
			if best_win then
				vim.api.nvim_set_current_win(best_win)
			end
		end
		return
	end

	-- Focus the existing left Neo-tree window (keeps current source: files/buffers/git).
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if is_neotree_ft(vim.bo[buf].filetype) then
			local pos = vim.api.nvim_win_get_position(win)
			if pos[2] == 0 then
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end

	-- Fall back to opening/focusing Neo-tree if there is no visible left sidebar yet.
	vim.cmd("Neotree focus")
end, { desc = "Toggle left sidebar / active file" })

-- This section adds the current git branch to the winbar of neo-tree windows.
-- It uses Fugitive's `FugitiveHead()` function to get the current branch name, and updates the winbar whenever relevant events occur (like changing directories, switching git branches, etc.).
local function neotree_git_branch_label()
	local branch = ""

	if vim.fn.exists("*FugitiveHead") == 1 then
		branch = vim.fn.FugitiveHead()
	end

	if branch == nil or branch == "" then
		return "%#NeoTreeWinbarTitle# Neo-tree"
	end

	return "%#NeoTreeWinbarTitle# Neo-tree  %#NeoTreeWinbarBranch#git:" .. branch
end

local function set_neotree_winbar_highlights()
	vim.api.nvim_set_hl(0, "NeoTreeWinbarTitle", { fg = "#7aa2f7", bold = true })
	vim.api.nvim_set_hl(0, "NeoTreeWinbarBranch", { fg = "#9ece6a", bold = true })
end

local function refresh_neotree_winbar()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "neo-tree" then
			vim.api.nvim_set_option_value("winbar", neotree_git_branch_label(), { scope = "local", win = win })
		end
	end
end

-- Improve responsiveness to external file & git changes.
vim.opt.autoread = true

local neotree_refresh_pending = false
local function refresh_neotree_sources()
	if neotree_refresh_pending then
		return
	end
	neotree_refresh_pending = true

	vim.defer_fn(function()
		neotree_refresh_pending = false

		pcall(vim.cmd, "silent! checktime")

		local has_neotree = false
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].filetype == "neo-tree" then
				has_neotree = true
				break
			end
		end
		if not has_neotree then
			return
		end

		local ok, command = pcall(require, "neo-tree.command")
		if not ok then
			return
		end

		pcall(command.execute, { action = "refresh", source = "filesystem" })
		pcall(command.execute, { action = "refresh", source = "git_status" })
	end, 80)
end

local neotree_start_width = nil

local function set_cwd_from_start_arg()
	if vim.fn.argc() == 0 then
		return
	end

	local first_arg = vim.fn.argv(0)
	if first_arg == nil or first_arg == "" then
		return
	end

	local abs_path = vim.fn.fnamemodify(first_arg, ":p")
	local start_dir = vim.fn.isdirectory(abs_path) == 1 and abs_path or vim.fn.fnamemodify(abs_path, ":h")

	local root = vim.fs.root(start_dir, {
		".git",
		"go.work",
		"go.mod",
		"package.json",
		"pyproject.toml",
		"Cargo.toml",
		"Makefile",
	})

	local target_dir = root or start_dir
	if target_dir ~= nil and target_dir ~= "" then
		vim.cmd("cd " .. vim.fn.fnameescape(target_dir))
	end
end

local neotree_branch_augroup = vim.api.nvim_create_augroup("neotree-branch-winbar", { clear = true })
set_neotree_winbar_highlights()
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "DirChanged", "FocusGained", "TermClose" }, {
	group = neotree_branch_augroup,
	pattern = "*",
	callback = function()
		refresh_neotree_winbar()
		-- Keep filesystem + git_status panes current (especially after external changes).
		refresh_neotree_sources()
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	group = neotree_branch_augroup,
	pattern = "*",
	callback = set_neotree_winbar_highlights,
})

-- Trigger after Fugitive git actions like :Git switch.
vim.api.nvim_create_autocmd("User", {
	group = neotree_branch_augroup,
	pattern = "FugitiveChanged",
	callback = function()
		refresh_neotree_winbar()
		refresh_neotree_sources()
	end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
	group = neotree_branch_augroup,
	pattern = "*",
	callback = refresh_neotree_sources,
})

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			set_cwd_from_start_arg()
			vim.cmd("Neotree show")
			refresh_neotree_winbar()

			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "neo-tree" then
					neotree_start_width = vim.api.nvim_win_get_width(win)
					break
				end
			end
		end)
	end,
})

-- Keep startup-like layout: if only Neo-tree remains, recreate an editor pane.
local function ensure_editor_pane_with_neotree()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	if #wins ~= 1 then
		return
	end

	local only_win = wins[1]
	local buf = vim.api.nvim_win_get_buf(only_win)
	if vim.bo[buf].filetype ~= "neo-tree" then
		return
	end

	vim.api.nvim_set_current_win(only_win)
	vim.cmd("vnew")
	vim.api.nvim_win_set_width(only_win, neotree_start_width or 40)
end

local neotree_layout_augroup = vim.api.nvim_create_augroup("neotree-keep-layout", { clear = true })
vim.api.nvim_create_autocmd({ "WinClosed", "BufEnter", "TabEnter" }, {
	group = neotree_layout_augroup,
	pattern = "*",
	callback = function()
		vim.schedule(ensure_editor_pane_with_neotree)
	end,
})

-- Autosave on leaving insert mode, except for filetypes whose formatters are slow
-- (terraform/terragrunt/hcl run on save and can block the UI up to conform's timeout).
local autosave_skip_ft = { terraform = true, terragrunt = true, hcl = true }
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		if not autosave_skip_ft[vim.bo.filetype] then
			vim.cmd("silent! write")
		end
	end,
})

vim.keymap.set("n", "<leader>n", "<cmd>tabnew<CR>", { desc = "New tab" })

-- git
local function find_git_backed_window()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		local buftype = vim.bo[buf].buftype
		local filetype = vim.bo[buf].filetype
		local name = vim.api.nvim_buf_get_name(buf)
		if buftype == "" and filetype ~= "gitsigns-blame" and name ~= "" then
			local file_dir = vim.fn.fnamemodify(name, ":h")
			local root_result = vim.system({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" }, { text = true })
				:wait()
			if root_result.code == 0 then
				return win, buf
			end
		end
	end

	return nil, nil
end

local function open_github_commit(commit, win)
	vim.api.nvim_win_call(win, function()
		vim.cmd("GBrowse " .. commit)
	end)
end

local function get_commit_for_buffer_line(bufnr, line)
	local file_path = vim.api.nvim_buf_get_name(bufnr)

	if file_path == "" then
		return nil, "Current buffer has no file path", vim.log.levels.WARN
	end

	local file_dir = vim.fn.fnamemodify(file_path, ":h")
	local root_result = vim.system({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if root_result.code ~= 0 then
		return nil, "Current file is not inside a git repository", vim.log.levels.WARN
	end

	local repo_root = vim.trim(root_result.stdout or "")
	local relative_path = vim.fs.relpath(repo_root, file_path)
	if not relative_path then
		return nil, "Could not resolve file path inside repository", vim.log.levels.ERROR
	end

	local blame_result = vim.system({
		"git",
		"-C",
		repo_root,
		"blame",
		"--line-porcelain",
		"-L",
		string.format("%d,+1", line),
		"--",
		relative_path,
	}, { text = true }):wait()

	if blame_result.code ~= 0 then
		local message = vim.trim(blame_result.stderr or "")
		if message == "" then
			message = "Failed to blame current line"
		end
		return nil, message, vim.log.levels.ERROR
	end

	local first_line = vim.split(blame_result.stdout or "", "\n", { plain = true })[1] or ""
	local commit = first_line:match("^([0-9a-f]+)%s")
	if not commit or commit:match("^0+$") then
		return nil, "Current line is not committed yet", vim.log.levels.WARN
	end

	return commit, nil, nil
end

local function open_github_commit_for_current_line()
	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local target_bufnr = bufnr
	local target_win = vim.api.nvim_get_current_win()

	if filetype == "gitsigns-blame" then
		local source_win, source_buf = find_git_backed_window()
		if not source_win or not source_buf then
			vim.notify("Could not find the source git buffer for this blame pane", vim.log.levels.ERROR)
			return
		end

		target_bufnr = source_buf
		target_win = source_win
	end

	local commit, message, level = get_commit_for_buffer_line(target_bufnr, line)
	if not commit then
		vim.notify(message, level)
		return
	end

	open_github_commit(commit, target_win)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "gomod", "gowork", "gosum" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = false -- Go uses real tabs, never spaces
	end,
})

-- fold settings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldenable = true

-- vim.keymap.set("n", "<leader>gb", ":Git switch ", { desc = "Git switch [B]ranch" })
vim.keymap.set("n", "<leader>gb", "<cmd>GBrowse<CR>", { desc = "[G]it [B]rowse" })
vim.keymap.set("n", "<leader>gL", "<cmd>.GBrowse<CR>", { desc = "[G]it browse [L]ine" })
vim.keymap.set("n", "<leader>gB", open_github_commit_for_current_line, { desc = "[G]it browse causing commit" })
vim.keymap.set("v", "<leader>gb", ":'<,'>GBrowse<CR>", { desc = "[G]it [B]rowse selection" })

-- copy all file
vim.keymap.set("n", "<leader>ya", 'gg"+yG', { desc = "Yank entire file" })
vim.keymap.set("n", "<leader>da", "ggdG", { desc = "Delete entire file contents" })
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Select entire file" })

-- paste over word without overwriting your register
vim.keymap.set("n", "<leader>rw", '"_diwP', { desc = "Replace word with yanked" })
vim.keymap.set("n", "<leader>dw", '"_diw', { desc = "Delete word (no register)" })
vim.keymap.set("n", "<leader>rl", '"_ddP', { desc = "Replace line with yanked" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete char (no register)" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down, keep centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up, keep centered" })

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>W", ":noa w<CR>", { desc = "Save without formatting" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- macOS-style copy: ensure Cmd+C/Meta+C always yanks (copy) without delete/change.
-- Some terminals send Cmd as <M-...>; GUIs can send <D-...>.
vim.keymap.set({ "n", "x" }, "<D-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "x" }, "<M-c>", '"+y', { desc = "Copy to system clipboard" })

-- disable accidental macro recording on q
vim.keymap.set("n", "q", "<nop>")

-- and use Q for macros instead (optional)
vim.keymap.set("n", "Q", "q")
