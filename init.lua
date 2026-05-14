--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	-- Can switch between these as you prefer
	virtual_text = true, -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
	jump = { float = true },
})

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- CUSTOM CONFIG:
vim.g.editorconfig = true

-- Do not auto-normalize EOF newlines when writing files.
vim.o.fixendofline = false

local gofmt_on_save = vim.api.nvim_create_augroup("go-fmt-on-save", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = gofmt_on_save,
	pattern = "*.go",
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			async = false,
			lsp_format = "fallback",
			formatters = { "gofmt" },
		})
		vim.bo[args.buf].endofline = true
		vim.bo[args.buf].fixendofline = true
	end,
})

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local treesitter_parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update

--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	-- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
	{ "NMAC427/guess-indent.nvim", opts = {} },

	-- Alternatively, use `config = function() ... end` for full control over the configuration.
	-- If you prefer to call `setup` explicitly, use:
	--    {
	--        'lewis6991/gitsigns.nvim',
	--        config = function()
	--            require('gitsigns').setup({
	--                -- Your gitsigns configuration here
	--            })
	--        end,
	--    }
	--
	-- Here is a more advanced example where we pass configuration
	-- options to `gitsigns.nvim`.
	--
	-- See `:help gitsigns` to understand what the configuration keys do
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		---@module 'gitsigns'
		---@type Gitsigns.Config
		---@diagnostic disable-next-line: missing-fields
		opts = {
			signs = {
				add = { text = "+" }, ---@diagnostic disable-line: missing-fields
				change = { text = "~" }, ---@diagnostic disable-line: missing-fields
				delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
				topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
				changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
			},
		},
	},

	-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
	--
	-- This is often very useful to both group configuration, as well as handle
	-- lazy loading plugins that don't need to be loaded immediately at startup.
	--
	-- For example, in the following configuration, we use:
	--  event = 'VimEnter'
	--
	-- which loads which-key before all the UI elements are loaded. Events can be
	-- normal autocommands events (`:help autocmd-events`).
	--
	-- Then, because we use the `opts` key (recommended), the configuration runs
	-- after the plugin has been loaded as `require(MODULE).setup(opts)`.

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter",
		---@module 'which-key'
		---@type wk.Opts
		---@diagnostic disable-next-line: missing-fields
		opts = {
			-- delay between pressing a key and opening which-key (milliseconds)
			delay = 0,
			icons = { mappings = vim.g.have_nerd_font },

			-- Document existing key chains
			spec = {
				{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
				{ "<leader>d", group = "[D]ebug" },
				{ "<leader>R", group = "[R]un tests" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "gr", group = "LSP Actions", mode = { "n" } },
			},
		},
	},

	-- NOTE: Plugins can specify dependencies.
	--
	-- The dependencies are proper plugin specifications as well - anything
	-- you do for a plugin at the top level, you can do for a dependency.
	--
	-- Use the `dependencies` key to specify the dependencies of a particular plugin

	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		-- By default, Telescope is included and acts as your picker for everything.

		-- If you would like to switch to a different picker (like snacks, or fzf-lua)
		-- you can disable the Telescope plugin by setting enabled to false and enable
		-- your replacement picker by requiring it explicitly (e.g. 'custom.plugins.snacks')

		-- Note: If you customize your config for yourself,
		-- it’s best to remove the Telescope plugin config entirely
		-- instead of just disabling it here, to keep your config clean.
		enabled = true,
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- Telescope is a fuzzy finder that comes with a lot of different things that
			-- it can fuzzy find! It's more than just a "file finder", it can search
			-- many different aspects of Neovim, your workspace, LSP, and more!
			--
			-- The easiest way to use Telescope, is to start by doing something like:
			--  :Telescope help_tags
			--
			-- After running this command, a window will open up and you're able to
			-- type in the prompt window. You'll see a list of `help_tags` options and
			-- a corresponding preview of the help.
			--
			-- Two important keymaps to use while in Telescope are:
			--  - Insert mode: <c-/>
			--  - Normal mode: ?
			--
			-- This opens a window that shows you all of the keymaps for the current
			-- Telescope picker. This is really useful to discover what Telescope can
			-- do as well as how to actually do it!

			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				-- defaults = {
				--   mappings = {
				--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
				--   },
				-- },
				-- pickers = {}
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			local search_with_github_dirs = { ".", ".github" }
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", function()
				builtin.find_files({ search_dirs = search_with_github_dirs })
			end, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", function()
				builtin.live_grep({ search_dirs = search_with_github_dirs })
			end, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
			-- it is better explained there). This allows easily switching between pickers if you prefer using something else!
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf

					-- Find references for the word under your cursor.
					vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })

					-- Jump to the implementation of the word under your cursor.
					-- Useful when your language has ways of declaring types without an actual implementation.
					vim.keymap.set(
						"n",
						"gri",
						builtin.lsp_implementations,
						{ buffer = buf, desc = "[G]oto [I]mplementation" }
					)

					-- Jump to the definition of the word under your cursor.
					-- This is where a variable was first declared, or where a function is defined, etc.
					-- To jump back, press <C-t>.
					vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					vim.keymap.set("n", "grv", function()
						vim.cmd.vsplit()
						builtin.lsp_definitions()
					end, { buffer = buf, desc = "[G]oto [V]split [D]efinition" })

					-- Fuzzy find all the symbols in your current document.
					-- Symbols are things like variables, functions, types, etc.
					vim.keymap.set(
						"n",
						"gO",
						builtin.lsp_document_symbols,
						{ buffer = buf, desc = "Open Document Symbols" }
					)

					-- Fuzzy find all the symbols in your current workspace.
					-- Similar to document symbols, except searches over your entire project.
					vim.keymap.set(
						"n",
						"gW",
						builtin.lsp_dynamic_workspace_symbols,
						{ buffer = buf, desc = "Open Workspace Symbols" }
					)

					-- Jump to the type of the word under your cursor.
					-- Useful when you're not sure what type a variable is and you want to see
					-- the definition of its *type*, not where it was *defined*.
					vim.keymap.set(
						"n",
						"grt",
						builtin.lsp_type_definitions,
						{ buffer = buf, desc = "[G]oto [T]ype Definition" }
					)
				end,
			})

			-- Override default behavior and theme when searching
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			-- It's also possible to pass additional configuration options.
			--  See `:help telescope.builtin.live_grep()` for information about particular keys
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- LSP Plugins
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{
				"mason-org/mason.nvim",
				---@module 'mason.settings'
				---@type MasonSettings
				---@diagnostic disable-next-line: missing-fields
				opts = {},
			},
			-- Maps LSP server names between nvim-lspconfig and Mason package names.
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("grV", function()
						vim.cmd.vsplit()
						vim.lsp.buf.declaration()
					end, "[G]oto [V]split [D]eclaration")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--  See `:help lsp-config` for information about keys and how to configure
			local terraform_warning_filters = {
				"declared but not used",
				"variable has no type",
				"has no type",
			}

			local function terraform_root_dir(target)
				local path = nil

				if type(target) == "number" then
					path = vim.api.nvim_buf_get_name(target)
				elseif type(target) == "string" then
					path = target
				end

				if path and vim.startswith(path, "file://") then
					path = vim.uri_to_fname(path)
				end

				if not path or path == "" then
					path = vim.uv.cwd()
				end

				local stat = vim.uv.fs_stat(path)
				local start = (stat and stat.type == "file") and vim.fs.dirname(path) or path
				local dir = start

				while dir do
					-- Prefer the nearest Terraform/Terragrunt directory in monorepos.
					if vim.fn.filereadable(dir .. "/terragrunt.hcl") == 1 then
						return dir
					end

					local has_tf_file = #vim.fn.globpath(dir, "*.tf", false, true) > 0
						or #vim.fn.globpath(dir, "*.tf.json", false, true) > 0
						or #vim.fn.globpath(dir, "*.tfvars", false, true) > 0

					if has_tf_file then
						return dir
					end

					local parent = vim.fs.dirname(dir)
					if parent == dir then
						break
					end

					dir = parent
				end

				return start
			end

			local function terraform_on_attach(client, _)
				-- Treesitter handles highlighting; disabling semantic tokens reduces terraform-ls churn.
				client.server_capabilities.semanticTokensProvider = nil
			end

			local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
			local function terraform_publish_diagnostics(err, result, ctx, config)
				if result and result.diagnostics then
					result.diagnostics = vim.tbl_filter(function(diagnostic)
						local message = (diagnostic.message or ""):lower()
						local is_ignored_warning = false

						for _, filter in ipairs(terraform_warning_filters) do
							if message:find(filter, 1, true) then
								is_ignored_warning = true
								break
							end
						end

						return not is_ignored_warning
					end, result.diagnostics)
				end

				return default_publish_diagnostics(err, result, ctx, config)
			end

			---@type table<string, vim.lsp.Config>
			local servers = {
				-- clangd = {},
				gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},

				-- Terraform / Terragrunt
				terraformls = {
					root_dir = terraform_root_dir,
					on_attach = terraform_on_attach,
					handlers = {
						["textDocument/publishDiagnostics"] = terraform_publish_diagnostics,
					},
				},
				tflint = {
					root_dir = terraform_root_dir,
					handlers = {
						["textDocument/publishDiagnostics"] = terraform_publish_diagnostics,
					},
				},

				-- YAML / GitHub Actions
				yamlls = {
					settings = {
						yaml = {
							validate = true,
							hover = true,
							completion = true,
							schemaStore = {
								enable = true,
								url = "https://www.schemastore.org/api/json/catalog.json",
							},
							schemas = {
								["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
								["https://json.schemastore.org/github-action.json"] = "/action.{yml,yaml}",
							},
						},
					},
				},

				stylua = {}, -- Used to format Lua code

				-- Special Lua Config, as recommended by neovim help docs
				lua_ls = {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								version = "LuaJIT",
								path = { "lua/?.lua", "lua/?/init.lua" },
							},
							workspace = {
								checkThirdParty = false,
								-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
								--  See https://github.com/neovim/nvim-lspconfig/issues/3189
								library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
									"${3rd}/luv/library",
									"${3rd}/busted/library",
								}),
							},
						})
					end,
					settings = {
						Lua = {},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--
			-- To check the current status of installed tools and/or manually install
			-- other tools, you can run
			--    :Mason
			--
			-- You can press `g?` for help in this menu.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				-- You can add other tools here that you want Mason to install
				"goimports",
				"gofumpt",
				"golangci-lint",
				"actionlint",
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		---@module 'conform'
		---@type conform.setupOpts
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 4000,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofmt" },
				gomod = { "gofmt" },
				gowork = { "gofmt" },
				terraform = { "terraform_fmt" },
				["terraform-vars"] = { "terraform_fmt" },
				hcl = { "terragrunt_hclfmt" },
				terragrunt = { "terragrunt_hclfmt" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
				opts = {},
			},
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				-- 'default' (recommended) for mappings similar to built-in completions
				--   <c-y> to accept ([y]es) the completion.
				--    This will auto-import if your LSP supports it.
				--    This will expand snippets if the LSP sent a snippet.
				-- 'super-tab' for tab to accept
				-- 'enter' for enter to accept
				-- 'none' for no mappings
				--
				-- For an understanding of why the 'default' preset is recommended,
				-- you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				--
				-- All presets have the following mappings:
				-- <tab>/<s-tab>: move to right/left of your snippet expansion
				-- <c-space>: Open menu or open docs if already open
				-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
				-- <c-e>: Hide menu
				-- <c-k>: Toggle signature help
				--
				-- See :h blink-cmp-config-keymap for defining your own keymap
				preset = "default",

				-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
				--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			completion = {
				-- By default, you may press `<c-space>` to show the documentation.
				-- Optionally, set `auto_show = true` to show the documentation after a delay.
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path", "snippets" },
			},

			snippets = { preset = "luasnip" },

			-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
			-- which automatically downloads a prebuilt binary when enabled.
			--
			-- By default, we use the Lua implementation instead, but you may enable
			-- the rust implementation via `'prefer_rust_with_warning'`
			--
			-- See :h blink-cmp-config-fuzzy for more information
			fuzzy = { implementation = "lua" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true },
		},
	},

	{ -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("tokyonight").setup({
				styles = {
					comments = { italic = false }, -- Disable italics in comments
				},
			})

			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		---@module 'todo-comments'
		---@type TodoOptions
		---@diagnostic disable-next-line: missing-fields
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/nvim-mini/mini.nvim
		end,
	},

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		branch = "main",
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
		config = function()
			require("nvim-treesitter").setup({
				install_dir = treesitter_parser_dir,
			})
			vim.opt.runtimepath:prepend(vim.fs.joinpath(treesitter_parser_dir, ""))

			local parsers = {
				"bash",
				"c",
				"diff",
				"go",
				"gomod",
				"gosum",
				"gotmpl",
				"hcl",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"terraform",
				"vim",
				"vimdoc",
				"yaml",
			}
			require("nvim-treesitter").install(parsers)
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match

					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					-- check if parser exists and load it
					if not vim.treesitter.language.add(language) then
						return
					end
					-- enables syntax highlighting and other treesitter features
					vim.treesitter.start(buf, language)

					-- enables treesitter based folds
					-- for more info on folds see `:help folds`
					-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
					-- vim.wo.foldmethod = 'expr'

					-- enables treesitter based indentation
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
	-- init.lua. If you want these files, they are in the repository, so you can just download them and
	-- place them in the correct locations.

	-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
	--
	--  Here are some example plugins that I've included in the Kickstart repository.
	--  Uncomment any of the lines below to enable them (you will need to restart nvim).
	--
	require("kickstart.plugins.debug"),
	require("kickstart.plugins.indent_line"),
	-- require 'kickstart.plugins.lint',
	-- require 'kickstart.plugins.autopairs',
	require("kickstart.plugins.neo-tree"),
	require("kickstart.plugins.gitsigns"), -- adds gitsigns recommend keymaps
	{ "tpope/vim-fugitive", lazy = false },
	{ "tpope/vim-rhubarb" },
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			direction = "horizontal",
			size = function(_)
				return math.max(10, math.floor(vim.o.lines * 0.25))
			end,
			persist_size = true,
		},
	},
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	-- { "github/copilot.vim", lazy = false },

	-- {
	-- 	"CopilotC-Nvim/CopilotChat.nvim",
	-- 	dependencies = {
	-- 		{ "nvim-lua/plenary.nvim", branch = "master" },
	-- 	},
	-- 	build = "make tiktoken",
	-- 	cmd = {
	-- 		"CopilotChat",
	-- 		"CopilotChatOpen",
	-- 		"CopilotChatClose",
	-- 		"CopilotChatToggle",
	-- 		"CopilotChatPrompts",
	-- 		"CopilotChatModels",
	-- 	},
	-- 	keys = {
	-- 		{ "<leader>cc", "<cmd>CopilotChatToggle<CR>", desc = "Copilot Chat: Toggle" },
	-- 		{ "<leader>cp", "<cmd>CopilotChatPrompts<CR>", desc = "Copilot Chat: Prompts" },
	-- 		{ "<leader>ce", "<cmd>CopilotChat<CR>", desc = "Copilot Chat: Open" },
	-- 		{ "<leader>ce", "<cmd>CopilotChat<CR>", mode = "v", desc = "Copilot Chat: Open" },
	-- 	},
	-- 	opts = {
	-- 		model = "claude-sonnet-4.5",
	-- 		tools = "copilot",
	-- 		resources = { "buffer", "selection", "gitdiff" },
	-- 		diff = "unified",
	-- 		stop_on_function_failure = true,
	-- 		auto_insert_mode = true,
	-- 		mappings = {
	-- 			accept_diff = {
	-- 				normal = "<C-y>",
	-- 				insert = "<C-y>",
	-- 			},
	-- 		},
	-- 		window = {
	-- 			layout = "vertical",
	-- 			width = 0.45,
	-- 		},
	-- 	},
	-- },
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<C-y>",
					accept_word = "<M-w>",
					accept_line = "<M-j>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},

			panel = { enabled = true },
		},
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = function()
			local chat_open = "<cmd>CodeCompanionChat<CR>"

			return {
				{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CodeCompanion: Toggle" },
				{ "<leader>cp", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion: Prompts/Actions" },
				{ "<leader>ce", chat_open, desc = "CodeCompanion: Open" },
				{ "<leader>ce", chat_open, mode = "v", desc = "CodeCompanion: Open" },
			}
		end,
		opts = {
			-- NOTE: The log_level is in `opts.opts`
			opts = {
				log_level = "INFO", -- or "TRACE"
			},
		},
	},
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
	},
	{ "fatih/vim-go" },
	{ "charlespascoe/vim-go-syntax" },
	-- {
	-- 	"neoclide/coc.nvim",
	-- 	branch = "release",
	-- },
	{
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required

			-- Only one of these is needed.
			"sindrets/diffview.nvim", -- optional
			"esmuellert/codediff.nvim", -- optional

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			"ibhagwan/fzf-lua", -- optional
			"nvim-mini/mini.pick", -- optional
			"folke/snacks.nvim", -- optional
		},
		cmd = "Neogit",
		-- keys = {
		-- 	{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
		-- },
	},
	{ "sindrets/diffview.nvim" },
	-- {
	-- 	"nvim-lualine/lualine.nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- },
	-- {
	-- 	"mfussenegger/nvim-dap",
	-- 	keys = {
	-- 		{
	-- 			"<leader>dc",
	-- 			function()
	-- 				require("dap").continue()
	-- 			end,
	-- 			desc = "[D]ebug: [C]ontinue",
	-- 		},
	-- 		{
	-- 			"<leader>db",
	-- 			function()
	-- 				require("dap").toggle_breakpoint()
	-- 			end,
	-- 			desc = "[D]ebug: Toggle [B]reakpoint",
	-- 		},
	-- 		{
	-- 			"<leader>dB",
	-- 			function()
	-- 				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
	-- 			end,
	-- 			desc = "[D]ebug: Conditional [B]reakpoint",
	-- 		},
	-- 		{
	-- 			"<leader>di",
	-- 			function()
	-- 				require("dap").step_into()
	-- 			end,
	-- 			desc = "[D]ebug: Step [I]nto",
	-- 		},
	-- 		{
	-- 			"<leader>do",
	-- 			function()
	-- 				require("dap").step_over()
	-- 			end,
	-- 			desc = "[D]ebug: Step [O]ver",
	-- 		},
	-- 		{
	-- 			"<leader>dO",
	-- 			function()
	-- 				require("dap").step_out()
	-- 			end,
	-- 			desc = "[D]ebug: Step [O]ut",
	-- 		},
	-- 		{
	-- 			"<leader>dr",
	-- 			function()
	-- 				require("dap").repl.open()
	-- 			end,
	-- 			desc = "[D]ebug: Open [R]EPL",
	-- 		},
	-- 		{
	-- 			"<leader>dl",
	-- 			function()
	-- 				require("dap").run_last()
	-- 			end,
	-- 			desc = "[D]ebug: Run [L]ast",
	-- 		},
	-- 		{
	-- 			"<leader>dx",
	-- 			function()
	-- 				require("dap").terminate()
	-- 			end,
	-- 			desc = "[D]ebug: Terminate",
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	"leoluz/nvim-dap-go",
	-- 	ft = { "go" },
	-- 	dependencies = {
	-- 		"mfussenegger/nvim-dap",
	-- 	},
	-- 	build = function()
	-- 		vim.system({ "go", "install", "github.com/go-delve/delve/cmd/dlv@latest" }):wait()
	-- 	end,
	-- 	opts = function()
	-- 		local delve_path = vim.fn.exepath("dlv")
	-- 		if delve_path == "" then
	-- 			local gopath = vim.trim(vim.fn.system("go env GOPATH"))
	-- 			delve_path = gopath .. "/bin/dlv"
	-- 		end

	-- 		return {
	-- 			delve = {
	-- 				path = delve_path,
	-- 			},
	-- 		}
	-- 	end,
	-- 	keys = {
	-- 		{
	-- 			"<leader>dt",
	-- 			function()
	-- 				require("dap-go").debug_test()
	-- 			end,
	-- 			desc = "[D]ebug nearest [T]est",
	-- 		},
	-- 		{
	-- 			"<leader>dT",
	-- 			function()
	-- 				require("dap-go").debug_last_test()
	-- 			end,
	-- 			desc = "[D]ebug last [T]est",
	-- 		},
	-- 	},
	-- },
	{
		"nvim-neotest/neotest",
		ft = { "go" },
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			{
				"fredrikaverpil/neotest-golang",
				version = "*",
				build = function()
					vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
				end,
			},
		},
		keys = {
			{
				"<leader>Rn",
				function()
					require("neotest").run.run()
				end,
				desc = "Run [N]earest test",
			},
			{
				"<leader>Rf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run current test [F]ile",
			},
			{
				"<leader>Rp",
				function()
					require("neotest").run.run(vim.fn.expand("%:p:h"))
				end,
				desc = "Run current [P]ackage tests",
			},
			{
				"<leader>Ra",
				function()
					local file_path = vim.fn.expand("%:p")
					local root = vim.fs.root(file_path, { "go.work", "go.mod", ".git" }) or vim.fn.getcwd()
					require("neotest").run.run(root)
				end,
				desc = "Run [A]ll tests",
			},
			{
				"<leader>Rl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Run [L]ast test",
			},
			{
				"<leader>Ro",
				function()
					require("neotest").output.open({ last_run = true, enter = true, auto_close = true })
				end,
				desc = "Open last test [O]utput",
			},
			{
				"<leader>Rs",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Toggle test [S]ummary",
			},
			{
				"<leader>Rd",
				function()
					require("neotest").run.run({ suite = false, strategy = "dap" })
				end,
				desc = "[D]ebug nearest test",
			},
		},
		config = function()
			local neotest_ns = vim.api.nvim_create_namespace("neotest")
			vim.diagnostic.config({
				virtual_text = {
					format = function(diagnostic)
						local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " ")
						return message:gsub("^%s+", "")
					end,
				},
			}, neotest_ns)

			require("neotest").setup({
				adapters = {
					require("neotest-golang")({
						runner = "gotestsum",
						dap_mode = "dap-go",
					}),
				},
			})
		end,
	},
	-- {
	-- 	"rmagatti/auto-session",
	-- 	lazy = false,

	-- 	---enables autocomplete for opts
	-- 	---@module "auto-session"
	-- 	---@type AutoSession.Config
	-- 	opts = {
	-- 		suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
	-- 		-- log_level = 'debug',
	-- 	},
	-- },

	-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--    This is the easiest way to modularize your config.
	--
	--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
	-- { import = 'custom.plugins' },
	--
	{
		"MagicDuck/grug-far.nvim",
		opts = {},
		keys = {
			{ "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search & Replace" },
			{ "<leader>S", "<cmd>GrugFar<cr>", desc = "Search & Replace" },
			-- open with current word pre-filled
			-- {
			-- 	"<leader>sw",
			-- 	function()
			-- 		require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
			-- 	end,
			-- 	desc = "Search & Replace (cword)",
			-- },
			-- open scoped to current file
			-- {
			-- 	"<leader>sf",
			-- 	function()
			-- 		require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
			-- 	end,
			-- 	desc = "Search & Replace (current file)",
			-- },
		},
	},
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	--
	-- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
	-- Or use telescope!
	-- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
	-- you can continue same window with `<space>sr` which resumes last telescope search
}, { ---@diagnostic disable-line: missing-fields
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
--
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

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "silent! write",
})

vim.keymap.set("n", "<leader>n", "<cmd>tabnew<CR>", { desc = "New tab" })

-- terminal
local function find_terminal_window()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		local cfg = vim.api.nvim_win_get_config(win)
		if vim.bo[buf].buftype == "terminal" and cfg.relative == "" then
			return win
		end
	end

	return nil
end

local function ensure_normal_mode()
	if vim.api.nvim_get_mode().mode:sub(1, 1) == "t" then
		vim.cmd("stopinsert")
	end
end

local function toggle_terminal_focus()
	ensure_normal_mode()

	if vim.bo.buftype == "terminal" then
		vim.cmd("wincmd p")
		return
	end

	local term_win = find_terminal_window()
	if term_win then
		vim.api.nvim_set_current_win(term_win)
		return
	end

	vim.cmd("ToggleTerm")
end

local function toggle_terminal_visibility()
	ensure_normal_mode()

	if vim.bo.buftype == "terminal" then
		vim.cmd("wincmd p")
	end

	vim.cmd("ToggleTerm")
end

vim.keymap.set("n", "<leader>t", toggle_terminal_focus, { desc = "Toggle [T]erminal focus" })
vim.keymap.set({ "n", "t" }, "<C-\\>", toggle_terminal_visibility, { desc = "Toggle terminal visibility" })

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
vim.keymap.set("n", "<leader>gB", open_github_commit_for_current_line, { desc = "[G]it browse causing commit" })
vim.keymap.set("v", "<leader>gb", ":'<,'>GBrowse<CR>", { desc = "[G]it [B]rowse selection" })

-- copy all file
vim.keymap.set("n", "<leader>ya", "ggVGy", { desc = "Yank entire file" })
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
