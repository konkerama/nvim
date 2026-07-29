-- Custom vim options and autocmds

-- CUSTOM CONFIG:
vim.g.editorconfig = true

-- Do not auto-normalize EOF newlines when writing files.
vim.o.fixendofline = false

-- gofmt itself runs via conform's format_on_save (formatters_by_ft.go).
-- This autocmd only fixes the trailing-newline behavior for Go: fixendofline is
-- globally false (above), but Go files must keep gofmt's final newline.
local go_eof_fix = vim.api.nvim_create_augroup("go-eof-fix", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = go_eof_fix,
	pattern = "*.go",
	callback = function(args)
		vim.bo[args.buf].endofline = true
		vim.bo[args.buf].fixendofline = true
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.tf", "*.tfvars" },
	callback = function()
		vim.bo.filetype = "terraform"
	end,
})
