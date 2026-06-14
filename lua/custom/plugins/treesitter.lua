-- CUSTOM: Authoritative nvim-treesitter config and spec. Lives here (not init.lua) so all of
-- treesitter's setup is in one place. Sections marked CUSTOM are additions on top of the
-- upstream kickstart defaults that the rest mirrors.
---@module 'lazy'
---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	dependencies = {
		-- CUSTOM: function/class/parameter textobjects + navigation. Uses the `main`
		-- branch to match nvim-treesitter's `main` branch API.
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	},
	-- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
	config = function()
		-- CUSTOM: use a dedicated install dir so parsers are co-located with the plugin source
		local treesitter_parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"

		-- Restart treesitter highlighting from scratch for a buffer.
		-- Mirrors what close+reopen does: stops the current parser and starts a fresh one.
		-- Used to recover from incremental-parse desync (mid-edit or after formatter rewrites buffer).
		local function reset_ts_highlight(buf)
			local ft = vim.bo[buf].filetype
			local lang = vim.treesitter.language.get_lang(ft)
			if not lang then
				return
			end
			pcall(vim.treesitter.stop, buf)
			pcall(vim.treesitter.start, buf, lang)
		end

		require("nvim-treesitter").setup({
			install_dir = treesitter_parser_dir,
		})
		vim.opt.runtimepath:prepend(vim.fs.joinpath(treesitter_parser_dir, ""))

		-- CUSTOM: extended parser list beyond the kickstart defaults
		-- (kickstart base: bash c diff html lua luadoc markdown markdown_inline query vim vimdoc)
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
		-- After save: conform may rewrite the entire buffer (terraform_fmt, terragrunt_hclfmt, etc.).
		-- Force a full parser reset so highlights reflect the reformatted content.
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.tf", "*.tfvars", "*.hcl", "*.yml", "*.yaml" },
			callback = function(args)
				reset_ts_highlight(args.buf)
			end,
		})

		-- Manual escape hatch: reset treesitter highlighting on the current buffer.
		-- Useful when the incremental parser desyncs mid-edit (before saving).
		-- NOTE: uses <leader>tH (capital H); <leader>th is the buffer-local LSP inlay-hints
		-- toggle, which would otherwise shadow this map on any LSP-attached buffer.
		vim.keymap.set("n", "<leader>tH", function()
			reset_ts_highlight(vim.api.nvim_get_current_buf())
		end, { desc = "Reset [T]reesitter [H]ighlight" })

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

		-- CUSTOM: treesitter textobjects (select + move).
		require("nvim-treesitter-textobjects").setup({
			select = { lookahead = true },
			move = { set_jumps = true },
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		-- Select textobjects, e.g. `vaf`, `dif`, `cia`.
		local select_maps = {
			af = "@function.outer",
			["if"] = "@function.inner",
			ac = "@class.outer",
			ic = "@class.inner",
			aa = "@parameter.outer",
			ia = "@parameter.inner",
		}
		for lhs, query in pairs(select_maps) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(query, "textobjects")
			end, { desc = "Select " .. query })
		end

		-- Move between functions/classes. `set_jumps` records to the jumplist.
		vim.keymap.set({ "n", "x", "o" }, "]m", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })
		vim.keymap.set({ "n", "x", "o" }, "[m", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function start" })
		vim.keymap.set({ "n", "x", "o" }, "]]", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })
		vim.keymap.set({ "n", "x", "o" }, "[[", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class start" })
	end,
}
