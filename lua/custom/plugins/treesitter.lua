-- CUSTOM: Full config override for nvim-treesitter. This replaces the kickstart base config (init.lua)
-- because lazy.nvim's `config` cannot be additively merged. Sections marked CUSTOM below are
-- the additions; everything else is identical to the kickstart base.
--
-- To revert to kickstart defaults, delete this file — init.lua's spec takes over automatically.
---@module 'lazy'
---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	-- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
	config = function()
		-- CUSTOM: use a dedicated install dir so parsers are co-located with the plugin source
		local treesitter_parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"

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
}
